require 'sinatra'
require 'sinatra/reloader'
require 'pry'

get('/') do
  redirect('/join')
end

get('/join') do
  slim(:join_game)
end

post('/game') do
  @name = params['name']
  slim(:index)
end
