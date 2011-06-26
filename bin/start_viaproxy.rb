#!/usr/bin/env ruby
#encoding: utf-8

#
ENV_KEY = 'VIAPROXY_HOME'
if not ENV.has_key?(ENV_KEY) then
  puts "无法启动 ViaProxy，找不到环境变量：[VIAPROXY_HOME]"
  exit 1
end


VIAPROXY_HOME = ENV[ENV_KEY]
$:.unshift "#{VIAPROXY_HOME}/lib"

require 'viaproxy/parsing'

