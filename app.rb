require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require './lib/socket_server.rb'
require './lib/client.rb'

server = SocketServer.new()

get('/') do
  redirect('/join')
end

get('/join') do
  slim(:join_game)
end

post('/waiting_page') do
  server.start
  server.create_game_lobby(4)
  Thread.new { @client = Client.new(3002) }
  game = server.accept_new_client
  @name = params['name']
  slim(:waiting_page)
end
