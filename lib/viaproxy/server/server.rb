#encoding: utf-8
#
require 'ffi-rzmq'
require 'json'
require 'eventmachine'
require 'socket'  

require 'viaproxy'

if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  require 'win32/process'
  STDOUT.set_encoding Encoding.locale_charmap
end

module ViaProxy

  def send_json(socket, obj)
    msg = JSON::generate(obj)
    socket.send_string(msg)
  end

  def recv_json(socket)
    msg = socket.recv_string()
    return JSON::parse(msg)
  end

  #EventMachine 接收服务器进程
  #TODO: 处理终止
  class ServerConnection  < EventMachine::Connection

    def initialize()
      @zsocket = nil
    end

    def receive_data(data)
      #assert { @zsocket != nil }
      # 这里处理解包
      #
      @zsocket.send_string(data)
      msg = @zsocket.recv_string()
      self.send_data(msg)
    end

    def set_zsocket(zsocket)
      @zsocket = zsocket
    end

  end


  def self.server_service(log, entrance_url)

    EventMachine::run do

      host = '0.0.0.0'
      port = 9000
      log.info { "SERVER:\t服务器准备开始侦听 [#{host}:#{port}]…" }
      zcontext = ZMQ::Context.new()
      zsocket = zcontext.socket(ZMQ::REQ)
      zsocket.connect(entrance_url)

      EventMachine::start_server(host, port, ServerConnection) do |conn|
        conn.set_zsocket(zsocket)
      end

    end
  end

end
