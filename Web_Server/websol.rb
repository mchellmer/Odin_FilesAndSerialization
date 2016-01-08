require 'socket'
require 'json'
 
host = 'localhost'
port = 2000

name = "erik"
email = "erik@viking.dk"


request = "GET index.html HTTP/1.0"


puts "What kind of request do you want to send? (GET/POST)"
input = gets.chomp
if input == "GET"
  request = "GET index.html HTTP/1.0"
elsif input == "POST"
  puts "Input name:"
  name = gets.chomp
  puts "Input email:"
  email = gets.chomp
  params = {:viking => {:name => name, :email => email}}
  jsonparams = params.to_json

  request = "POST thanks.html HTTP/1.0 \n
               Content-Length : #{jsonparams.length}\r\n\r\n
               #{jsonparams}"
end

socket = TCPSocket.open(host,port)
socket.print(request)
response = socket.read
   
puts ""
puts "sent request '#{request}' to #{host} / port #{port}"
puts ""
puts "response :"
puts ""
puts response