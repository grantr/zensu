require 'zensu'
Zensu::Server::App.run!
Zensu::Client::App.run!

require './examples/config'
# Zensu.config.broadcast_endpoint = "tcp://127.0.0.1:58000"
# 
# Zensu.config.servers = ["tcp://127.0.0.1:58000"]

broadcaster = Celluloid::Actor.all.detect { |a| a.class == Zensu::Server::Broadcaster }
broadcaster.broadcast("topic", "hello")
sleep 1
