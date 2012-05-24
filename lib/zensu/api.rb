require 'zensu'
require 'reel'

Zensu.setup
api = Zensu::RPC::Requester.new
Reel::Server.new("0.0.0.0", 3000) do |connection|
  request = connection.request
  if request #TODO why does this occasionally return nil?
    puts "request: #{request.inspect}"
    puts "Client requested: #{request.method} #{request.url}"

    if request.method == :get && request.url = "/clients"
      response = api.request("get_clients")
      puts "got response: #{response}"
      connection.respond :ok, MultiJson.dump(response.result)
    else
      connection.respond :ok, "hello, world"
    end
  end
end

sleep
