require 'socket'
require 'json'

host = 'localhost'
port = 2000

path = "/index.html"

puts "What type of request would you like to send, POST or GET?"
answer = gets.chomp

case answer
  when 'GET'
    request = "GET #{path} HTTP/1.0"
  when 'POST'
    puts 'What is the name of your Viking?'
    name = gets.chomp
    puts "Cool! What is #{name}'s email?"
    email = gets.chomp
    viking = {:viking => {:name => name, :email => email}}
    
    line1 = "POST #{viking.to_json} HTTP/1.0"
    line2 = "Content-Length: #{viking.to_json.length}"
    request = "#{line1}\r\n#{line2}"
  else
    puts "Action failed, no viable request submitted"
end

socket = TCPSocket.open(host,port)
socket.print(request)
response = socket.read
puts response