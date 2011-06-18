#encoding: utf-8
#
require 'rubygems'
require 'ffi-rzmq'
require 'json'

# The "ventilator" function generates a list of numbers from 0 to 1000, and 
# sends those numbers down a zeromq "PUSH" connection to be processed by 
# listening workers, in a round robin load balanced fashion.
#
def send_json(socket, obj)
  msg = JSON::generate(obj)
  socket.send_string(msg)
end

def recv_json(socket)
  msg = socket.recv_string()
  return JSON::parse(msg)
end

def ventilator()
  puts "任务分配进程：PID=[#{Process.pid}]"
  # Initialize a zeromq context
  context = ZMQ::Context.new

  # Set up a channel to send work
  ventilator_send = context.socket(ZMQ::PUSH)
  ventilator_send.bind("tcp://127.0.0.1:5557")

  # Give everything a second to spin up and connect
  sleep 1.0

  # Send the numbers between 1 and 1 million as work messages
  for num in 0...1000
    work_message = { 'num' => num }
    send_json(ventilator_send, work_message)
  end

  sleep 1.0
  puts "任务分配进程正在退出"
end

# The "worker" functions listen on a zeromq PULL connection for "work" 
# (numbers to be processed) from the ventilator, square those numbers,
# and send the results down another zeromq PUSH connection to the 
# results manager.

def worker(wrk_num)
  # Initialize a zeromq context
  wrk_num = Process.pid
  puts "正在启动工作者进程 PID=[#{wrk_num}]"

  context = ZMQ::Context.new

  # Set up a channel to receive work from the ventilator
  work_receiver = context.socket(ZMQ::PULL)
  work_receiver.connect("tcp://127.0.0.1:5557")

  # Set up a channel to send result of work to the results reporter
  results_sender = context.socket(ZMQ::PUSH)
  results_sender.connect("tcp://127.0.0.1:5558")

  # Set up a channel to receive control messages over
  control_receiver = context.socket(ZMQ::SUB)
  control_receiver.connect("tcp://127.0.0.1:5559")
  control_receiver.setsockopt(ZMQ::SUBSCRIBE, "")

  # Set up a poller to multiplex the work receiver and control receiver channels
  poller = ZMQ::Poller.new
  poller.register(work_receiver, ZMQ::POLLIN)
  poller.register(control_receiver, ZMQ::POLLIN)

  # Loop and accept messages from both channels, acting accordingly
  keep_alive = true
  while keep_alive
    poller.poll(:blocking)
    poller.readables.each do |socket|
      # If the message came from work_receiver channel, square the number
      # and send the answer to the results reporter
      if socket === work_receiver then
        work_message = recv_json(work_receiver)
        product = work_message['num'] * work_message['num']
        answer_message = { 'worker' => wrk_num, 'result' => product }
        send_json(results_sender, answer_message)
      end

      # If the message came over the control channel, shut down the worker.
      if socket === control_receiver then
        control_message = control_receiver.recv_string
        if control_message == "FINISHED" then
          puts "工作者进程 PID=[#{wrk_num}] 接受到 'FINISHED'指令，正在退出 "
          keep_alive = false
          break
        end
      end
    end
  end

  # The "results_manager" function receives each result from multiple workers,
  # and prints those results.  When all results have been received, it signals
  # the worker processes to shut down.
end

def result_sink()
  puts "我是结果收集进程，PID=[#{Process.pid}]"
  # Initialize a zeromq context
  context = ZMQ::Context.new

  # Set up a channel to receive results
  results_receiver = context.socket(ZMQ::PULL)
  results_receiver.bind("tcp://127.0.0.1:5558")

  # Set up a channel to send control commands
  control_sender = context.socket(ZMQ::PUB)
  control_sender.bind("tcp://127.0.0.1:5559")

  for task_nbr in 0...1000
    result_message = recv_json(results_receiver)
    puts "工作者进程 PID=[#{result_message['worker']}] 返回结果=[#{result_message['result']}]"
  end

  # Signal to all workers that we are finsihed
  control_sender.send_string("FINISHED")
  sleep 2.0
  puts "结果收集进程正在退出"
end


# 启动工作者进程
worker_pool = 10
for wrk_num in 0...worker_pool
  Process.fork do
    worker wrk_num
  end
end

# 启动结果收集进程
result_sink_pid = Process.fork do
  result_sink
end

# 启动分配器
Process.fork do
  ventilator 
end

Process.waitpid(result_sink_pid)
puts "主进程退出"
