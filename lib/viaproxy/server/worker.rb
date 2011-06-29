#encoding: utf-8
require 'ffi-rzmq'
require 'json'

require 'viaproxy'
#工人进程

module ViaProxy

  def self.worker_service(log, id, worker_url, supervisor_url)
    log.info { "WORKDER:\t启动工人进程: ID=[#{id}]" }


    context = ZMQ::Context.new

    # 连接到 supervisor
    control_socket = context.socket(ZMQ::SUB)
    control_socket.connect(supervisor_url)
    control_socket.setsockopt(ZMQ::SUBSCRIBE, "")
    log.info { "WORKDER:\tID=[#{id}] 成功连接到 Supervisor URL=[#{supervisor_url}]" }

    worker_socket = context.socket(ZMQ::REP)
    worker_socket.connect(worker_url)
    log.info { "WORKDER:\tID=[#{id}] 成功连接到 Worker URL=[#{worker_url}]" }

    poller = ZMQ::Poller.new()
    poller.register(worker_socket, ZMQ::POLLIN)
    poller.register(control_socket, ZMQ::POLLIN)

    keep_alive = true
    while keep_alive
      poller.poll(:blocking)
      poller.readables.each do |socket|

        if socket === worker_socket then
          message = worker_socket.recv_string()
          log.debug { "WORKER\t ID=[#{id}} 接收到消息：#{message}" }
          #TODO: 执行业务处理
          worker_socket.send_string("#{message} - Processed, Worker ID=[#{id}]")
        elsif socket ===  control_socket then
          control_message = control_socket.recv_string
          if control_message == "WORKER_TERMINATE" then
            keep_alive = false
            log.info { "WORKER\t ID=[#{id}] 接受到 'WORKER_TERMINATE'指令，正在退出" }
            break
          end
        end

      end

    end

    log.info { "WORKER:\t工人进程正常终止" }

  end
end

