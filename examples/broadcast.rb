require 'zensu'
Zensu::Server::App.run!
Zensu::Client::App.run!

require './examples/config'
# Zensu.config.broadcast_endpoint = "tcp://127.0.0.1:58000"
# 
# Zensu.config.servers = ["tcp://127.0.0.1:58000"]

Celluloid::Actor[:broadcaster].broadcast("topic", "hello")
sleep 5
