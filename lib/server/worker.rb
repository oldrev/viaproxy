#encoding: utf-8
require 'ffi-rzmq'
require 'json'

if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
  require 'win32/process'
  STDOUT.set_encoding Encoding.locale_charmap
end

#工人进程
def worker(id, url)
  context = ZMQ::Context.new
  zsocket = context.socket(ZMQ::REP)
  zsocket.connect(url)

  loop do
    message = zsocket.recv_string()
    zsocket.send_string("#{message} - Processed, Worker ID=[#{id}]")
  end
end

f = IO.read("worker-conf.js")
WORKER_CONFIG = JSON.parse(f)
MAX_WORKERS = WORKER_CONFIG["max_workers"]
puts "工人进程数：[#{MAX_WORKERS}]"
WORKER_URL = WORKER_CONFIG["worker_url"]

#开始生成工作进程
MAX_WORKERS.times do |id|

  Process.fork do
    puts "WORKDER:\t启动工人进程: ID=[#{id}]"
    worker(id, WORKER_URL)
  end

end

puts "工人进程主进程退出"
