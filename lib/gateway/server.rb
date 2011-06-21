#encoding: utf-8
#
require 'ffi-rzmq'
require 'json'
require 'eventmachine'
require 'socket'  


# The "ventilator" function generates a list of numbers from 0 to 1000, and 
# sends those numbers down a zeromq "PUSH" connection to be processed by 
# listening workers, in a round robin load balanced fashion.
#
if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  require 'win32/process'
  STDOUT.set_encoding Encoding.locale_charmap
end

def send_json(socket, obj)
  msg = JSON::generate(obj)
  socket.send_string(msg)
end

def recv_json(socket)
  msg = socket.recv_string()
  return JSON::parse(msg)
end

f = IO.read("server-conf.js")
SERVER_CONFIG = JSON.parse(f)
ENTRANCE_URL = SERVER_CONFIG["entrance_url"]

#EventMachine 接收服务器进程
class ServerConnection  < EventMachine::Connection
  
  @@context = ZMQ::Context.new()
  @@zsocket = @@context.socket(ZMQ::REQ)
  @@zsocket.connect(ENTRANCE_URL)

  def receive_data(data)
    # 这里处理解包
    #
    @@zsocket.send_string(data)
    msg = @@zsocket.recv_string()
    self.send_data(msg)
  end
end


def server_process(entrance_url)
  EventMachine::run do
    host = '0.0.0.0'
    port = 9000
    EventMachine::start_server host, port, ServerConnection
    puts "SERVER:\t服务器已开始侦听 #{host}:#{port}…"
  end
end

Process.fork do
  server_process(ENTRANCE_URL)
end

puts "服务器主进程退出"
