require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'sinatra/base'
require './lib/game.rb'
require 'pusher'

$clients = []
$names = []

class MyApp < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  def self.game
    @@game ||= Game.new(4)
  end

  def pusher_client
    @pusher_client ||= Pusher::Client.new(
    app_id: '547524',
    key: '5b23c1673191a16f606d',
    secret: 'ac2726f0b7be73376d66',
    cluster: 'us2',
    encrypted: true)
  end

  get('/') do
    redirect('/join')
  end

  get('/join') do
    slim(:join_game)
  end

  post('/join') do
    player = self.class.game.create_player(params['name'])
    session[:current_player] = player.name

    pusher_client.trigger('app', 'game-changed', {
      message: "Added Player: #{player.name}"
    })
    redirect '/waiting_page'
  end

  get('/waiting_page') do
    players_array = self.class.game.players_array
    if players_array.length == 4
      redirect '/game'
    end
    slim :waiting_page, locals: {
      players_array: self.class.game.players_array,
      current_player: session[:current_player]
    }
  end

  get('/game') do
    slim :index, locals: {
      players_array: self.class.game.players_array,
      current_player: session[:current_player]
    }
  end
end
