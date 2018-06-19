require 'sinatra'
require 'sinatra/reloader'
require 'pry'
Thread.new { require './lib/server_starter.rb' }
require './lib/client.rb'
require 'sinatra/base'

class MyApp < Sinatra::Base
  get('/') do
    redirect('/join')
  end

  get('/join') do
    slim(:join_game)
  end

  post('/waiting_page') do
    @client = Client.new(3002)
    sleep(0.1)
    @name = params['name']
    slim(:waiting_page)
  end

  post('/game') do
    slim(:index)
  end
end
