#encoding: utf-8
require 'ffi-rzmq'
require 'json'

require 'viaproxy'
#工人进程

module ViaProxy

  def self.worker_service(log, id, url)
    log.info { "WORKDER:\t启动工人进程: ID=[#{id}]" }
    context = ZMQ::Context.new
    zsocket = context.socket(ZMQ::REP)
    zsocket.connect(url)

    loop do
      message = zsocket.recv_string()
      zsocket.send_string("#{message} - Processed, Worker ID=[#{id}]")
    end

    log.info { "WORKER:\t工人进程正常终止" }

  end
end

