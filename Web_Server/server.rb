require 'socket'
require 'json'
require 'erb'

server = TCPServer.new('localhost',2000)
loop {
  client = server.accept
  begin
    request = client.read_nonblock(256)
  rescue
    retry
  end
  
  puts "Request received: " + request

  request_header,request_body = request.split("\r\n\r\n",2)
  request_array = request_header.split(" ")
  
  command = request_array[0]
  content = request_array[1]
  version = request_array[2]
  
  if command == "GET"
    line1 = "HTTP/1.0 200 OK"
    line2 = "Date: #{Time.now.ctime}"
    line3 = 'Content-Type: text/html'
    line5 = File.read(content[1..-1])
    line4 = "Content-length: #{line5.length}"
    
    response = "#{line1}\r\n#{line2}\r\n#{line3}\r\n#{line4}\r\n\r\n#{line5}"
    client.puts(response)
  elsif command == "POST"
    params = JSON.parse(content)
    
    name = params['viking']['name']
    email = params['viking']['email']
    
    template = File.read('thanks.html')
    body = template.gsub("<%= yield %>", "<li>Name: #{name}</li><li>Email: #{email}</li>")
    
    line1 = "HTTP/1.0 200 OK"
    line2 = "Date: #{Time.now.ctime}"
    line3 = 'Content-Type: text/html'
    line5 = body
    line4 = "Content-length: #{line5.length}"
    response = "#{line1}\r\n#{line2}\r\n#{line3}\r\n#{line4}\r\n\r\n#{body}"
    client.puts(response)
  else
    puts 'File not found: 404'
  end
  
  client.close
}