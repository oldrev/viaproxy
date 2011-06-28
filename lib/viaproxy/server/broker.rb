#encoding: utf-8
#
require 'ffi-rzmq'
require 'json'

if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  require 'win32/process'
  STDOUT.set_encoding Encoding.locale_charmap
end

module ViaProxy

  # 请求代理进程  
  def self.broker_service(log, worker_url, entrance_url)
    log.info "BROKER:\t启动请求代理进程..."

    context = ZMQ::Context.new(1)

    clients = context.socket(ZMQ::XREP)
    clients.bind(entrance_url)

    workers = context.socket(ZMQ::XREQ)
    workers.bind(worker_url)

    ZMQ::Device.new(ZMQ::QUEUE, clients, workers) 

    log.info "BROKER:\t请求代理进程准备退出"

    clients.close()
    workers.close()
    context.term()

    log.info "BROKER:\t请求代理进程成功退出"
  end

end
