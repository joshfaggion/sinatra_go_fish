require 'socket'
require_relative 'socket_server'


server = SocketServer.new
server.start
server.create_game_lobby(4)
loop do
  game = server.accept_new_client
  if game
    Thread.new do
      server.run_game(game)
    end
  end
rescue
  server.stop
end
