require 'socket'

s = TCPSocket.open("localhost", 9000)

for i in 0..100
  puts i
  s.write("Hello![#{i}]\n")
  puts s.gets()
end

s.close

