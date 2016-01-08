require 'socket'
require 'json'

server = TCPServer.open(2000)
loop {
  client = server.accept
  request = client.read
  puts "Received request : " + request

  request_header,request_body = request.split("\r\n\r\n", 2)
  request_array = request_header.split(" ")
  method = request_array[0]
  path = request_array[1]


  if File.exist?(path)
    response = File.read(path)
    client.puts("HTTP/1.0 200 OK")

    case method.upcase
    when "GET"
      client.puts(response)
    when "POST"
      params = {}
      params = JSON.parse(request_body)
      data = "<li> Name : #{params['viking']['name']}</li> <li> Email : #{params['viking']['email']}</li>"
      client.print response.gsub("<%= yield %>", data)
    end
  else
    client.puts("HTTP/1.0 404 File not found")
end

  client.close
}