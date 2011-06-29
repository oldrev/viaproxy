#encoding: utf-8
#
require 'ffi-rzmq'

if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  STDOUT.set_encoding Encoding.locale_charmap
end

module ViaProxy

  # 请求代理进程  
  def self.broker_service(log, worker_url, entrance_url)
    log.info "BROKER:\t启动请求业务消息路由中间件进程..."

    context = ZMQ::Context.new(1)

    log.info "BROKER:\t开始侦听 WORKER URL=[#{worker_url}]"
    workers = context.socket(ZMQ::XREQ)
    workers.bind(worker_url)

    log.info "BROKER:\t开始侦听 ENTRANCE URL=[#{entrance_url}]"
    clients = context.socket(ZMQ::XREP)
    clients.bind(entrance_url)

    log.info "BROKER:\t创建路由消息队列"
    ZMQ::Device.new(ZMQ::QUEUE, clients, workers) 

    log.info "BROKER:\t业务消息路由进程准备终止"

    clients.close()
    workers.close()
    context.term()

    log.info "BROKER:\t业务消息路由进程成功终止"
  end

end
