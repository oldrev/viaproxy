#encoding: utf-8
#
require 'ffi-rzmq'

if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  STDOUT.set_encoding Encoding.locale_charmap
end

module ViaProxy

  def self.proxy_message(message, src, dest)
    loop do
      src.recv(message)
      more = src.more_parts?
      dest.send(message, more ? ZMQ::SNDMORE : 0)
      break unless more
    end
  end

  # 用于负载均衡的业务消息路由进程  
  # TODO: 改写成 C 的，添加
  def self.broker_service(log, worker_url, entrance_url)

    log.info { "BROKER:\t启动业务消息路由中间件进程..." }

    context = ZMQ::Context.new()

    log.info { "BROKER:\t开始侦听 ENTRANCE URL=[#{entrance_url}]" }
    frontend = context.socket(ZMQ::XREP)
    frontend.bind(entrance_url)

    log.info { "BROKER:\t开始侦听 WORKER URL=[#{worker_url}]" }
    backend = context.socket(ZMQ::XREQ)
    backend.bind(worker_url)

    poller = ZMQ::Poller.new
    poller.register(frontend, ZMQ::POLLIN)
    poller.register(backend, ZMQ::POLLIN)

    log.info { "BROKER:\t启动路由消息队列" }
    message = ZMQ::Message.new()
    loop do
      poller.poll(:blocking)
      poller.readables.each do |socket|
        if socket === frontend
          proxy_message(message, socket, backend)
        elsif socket === backend
          proxy_message(message, socket, frontend)
        end
      end
    end

    log.info "BROKER:\t业务消息路由进程成功终止"
    frontend.close()
    backend.close()
    context.term()

  end

end
