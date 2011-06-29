#encoding: utf-8
#
#
#
require 'json'
require 'ffi-rzmq'

module ZMQ

  class Socket

    def send_json(obj) 
      msg = JSON::generate(obj)
      self.send_string(msg)
    end

    def recv_json()
      msg = self.recv_string()
      return JSON::parse(msg)
    end

  end

end
