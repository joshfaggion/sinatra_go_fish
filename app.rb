require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'sinatra/base'
require './lib/game.rb'
require 'pusher'

class MyApp < Sinatra::Base
  enable :sessions
  @@counter = 0
  @@pending_players = []

  configure :development do
    register Sinatra::Reloader
  end

  def self.game
    @@game ||= Game.new(4)
  end

  def pusher_client
    @@pusher_client ||= Pusher::Client.new(
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
    @@pending_players.push(player.name)
    session[:current_player] = player.name
    pusher_client.trigger('app', 'game-changed', {
      message: "Added Player: #{session[:current_player]}"
    })
    redirect '/waiting_page'
  end

  get('/waiting_page') do
    players_array = self.class.game.players_array
    if @@pending_players.length % 4 == 0
      @@current_players = @@pending_players.shift(4)
      redirect '/game'
    end
    slim :waiting_page, locals: {
      pending_players: @@pending_players,
      current_player: session[:current_player]
    }
  end

  get('/game') do
    if @@counter == 0
      @@counter += 1
      self.class.game.begin_game
    end
    slim :index, locals: {
      players_array: self.class.game.players_array,
      current_player: session[:current_player],
      current_players: @@current_players
    }
  end
end
