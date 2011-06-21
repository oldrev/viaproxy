#encoding: utf-8
#
require 'ffi-rzmq'
require 'json'


# The "ventilator" function generates a list of numbers from 0 to 1000, and 
# sends those numbers down a zeromq "PUSH" connection to be processed by 
# listening workers, in a round robin load balanced fashion.
#
if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  require 'win32/process'
  STDOUT.set_encoding Encoding.locale_charmap
end

f = IO.read("server-conf.js")
SERVER_CONFIG = JSON.parse(f)

# 请求代理进程
def broker(worker_url, entrance_url)
  puts "BROKER:\t启动请求代理进程..."
  context = ZMQ::Context.new(1)

  clients = context.socket(ZMQ::XREP)
  clients.bind(entrance_url)

  workers = context.socket(ZMQ::XREQ)
  workers.bind(worker_url)

  ZMQ::Device.new(ZMQ::QUEUE, clients, workers) 

  clients.close()
  workers.close()
  context.term()
end

Process.fork do
  worker_url = SERVER_CONFIG["worker_url"]
  entrance_url = SERVER_CONFIG["entrance_url"]
  broker(worker_url, entrance_url)
end

puts "BROKER 主进程退出"
