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
    sleep(0.1)
    if @@counter == 0
      @@counter += 1
      self.class.game.begin_game
      # Testing End Game
      # self.class.game.clear_deck
      # player1 = @@game.find_player(1)
      # player2 = @@game.find_player(2)
      # player3 = @@game.find_player(3)
      # player4 = @@game.find_player(4)
      # player1.set_hand([])
      # player2.set_hand([])
      # player3.set_hand([])
      # player4.set_hand([])
      # player3.give_point()
    end
    if @@game.winner?
      @@winner = @@game.find_player(@@game.who_is_winner).name
      @@counter = 0
      redirect('/game_completed')
    end
    local_players = []
    player_id = 0
    self.class.game.players_array.each do |player|
      local_players.push(player)
    end
    local_players.each do |player|
      if player.name == session[:current_player]
        player_id = local_players.index(player)
      end
    end
    player = local_players.delete_at(player_id)
    result = ""
    responses = self.class.game.last_five_responses
    slim :index, locals: {
      local_players: local_players,
      player: player,
      turn: @@game.turn,
      player_id: player_id,
      responses: responses,
      result: result
    }
  end

  post('/game') do
    id_player = @@game.players_array[self.class.game.turn - 1]
    request = params['request']
    result = ""
    valid_request = id_player.valid_request(request)
    if valid_request && valid_request != "Invalid Request"
      result = @@game.run_round(valid_request)
    else
      result = false
    end
    local_players = []
    player_id = 0
    self.class.game.players_array.each do |player|
      local_players.push(player)
    end
    local_players.each do |player|
      if player.name == session[:current_player]
        player_id = local_players.index(player)
      end
    end
    player = local_players.delete_at(player_id)
    if valid_request && valid_request != "Invalid Request"
      pusher_client.trigger('app', 'game-updated', {
        message: "A request has been made! Look top right corner to see what just happened."
      })
    end
    responses = self.class.game.last_five_responses
    slim :index, locals: {
      local_players: local_players,
      player: player,
      turn: @@game.turn,
      player_id: player_id,
      responses: responses,
      result: result
    }
  end

  get('/game_completed') do
    sleep(0.1)
    @@game.reset_game
    @@game.begin_game
    slim :game_completed, locals: {
      winner: @@winner
    }
  end
end
