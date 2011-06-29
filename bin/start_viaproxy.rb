#!/usr/bin/env ruby
#encoding: utf-8
#
require 'json'
require 'logger'

if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  require 'win32/process'
end

#
ENV_KEY = 'VIAPROXY_HOME'
if not ENV.has_key?(ENV_KEY) then
  puts "Cannot start ViaProxy up, cannot found Environment Variable [VIAPROXY_HOME]"
  exit 1
end


VIAPROXY_HOME = ENV[ENV_KEY]
$:.unshift "#{VIAPROXY_HOME}/lib"

require 'viaproxy'
require 'viaproxy/server/broker'
require 'viaproxy/server/server'
require 'viaproxy/server/worker'

module ViaProxy

  MAIN_LOG_FILE_PATH = File.join(VIAPROXY_HOME, "log", "main.log")

  log = Logger.new(MAIN_LOG_FILE_PATH)
  log.datetime_format = "%Y-%m-%d %H:%M:%S"

  log.info { "ViaProxy 开始启动..." }

  SERVER_CONFIG_PATH = File.join(VIAPROXY_HOME, "etc", "server-conf.js")

  log.info "服务器配置文件=[#{SERVER_CONFIG_PATH}]"

  puts "ViaProxy 正在启动..."
  SERVER_CONFIG = JSON::parse(IO.read(SERVER_CONFIG_PATH))

  log.info "配置文件加载完毕"
  log.info "worker_url=[#{SERVER_CONFIG['worker_url']}]"
  log.info "entrance_url=[#{SERVER_CONFIG['entrance_url']}]"

  def fork_service_process()
    begin
      yield
    rescue => err
      log.fatal("引发了未知异常，正在退出")
      log.fatal(err)
      Process.exit(-1)
    end

  end

  Process.fork do
    begin
      ViaProxy::broker_service(log, SERVER_CONFIG['worker_url'], SERVER_CONFIG['entrance_url'])
    rescue => err
      log.fatal("BROKER 进程引发了未知异常，正在退出")
      log.fatal(err)
      Process.exit(-1)
    end
  end

  Process.fork do
    begin
      ViaProxy::server_service(log, SERVER_CONFIG['entrance_url'], SERVER_CONFIG['supervisor_url'])
    rescue => err
      log.fatal("SERVER 进程引发了未知异常，正在退出")
      log.fatal(err)
      Process.exit(-1)
    end
  end

  for i in 0..2
    Process.fork do
      begin
        ViaProxy::worker_service(log, i, SERVER_CONFIG['worker_url'], SERVER_CONFIG['supervisor_url'])
      rescue => err
        log.fatal("WORKER 进程引发了未知异常，正在退出")
        log.fatal(err)
        Process.exit(-1)
      end
    end
  end

  Process.waitall

end
