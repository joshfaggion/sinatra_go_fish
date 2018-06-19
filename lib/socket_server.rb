require 'pry'
require 'socket'
require_relative 'game'
require_relative 'request'


class SocketServer
  def initialize
    @games={}
    @lobbies = []
    @pending_clients = []
  end

  def accept_new_client(client='Random Player')
    # This will welcome the players, and direct them to the lobby.
    lobby_complete = lobbies.last[2]
    num_of_players = lobbies.last[0]
    joined_players = lobbies.last[1]
    client_connection = server.accept_nonblock
    pending_clients.push(client_connection)
    if lobby_complete == false
      if num_of_players > pending_clients.length
        lobbies.last[1] += 1
        client_connection.puts "Welcome, we are currently waiting for more players. You are Player #{lobbies.last[1]}."
        # For some reason I can't use joined_players here. Food for thought.
        return false
      else
         lobbies.last[1] += 1
         client_connection.puts "Welcome, a game lobby is complete! You are Player #{lobbies.last[1]}."
         lobbies.last[2] = true
         return create_game(4)
      end
    else
      client_connection.puts "Creating New Lobby..."
      create_game_lobby(4)
      joined_players = 1
      lobbies.last[1] += 1
      client_connection.puts "Welcome, we are currently waiting for more players. You are Player 1."
      return false
    end
  rescue IO::WaitReadable, Errno::EINTR
    sleep(0.1)
    return false
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def stop
    server.close if server
  end

  def create_game_lobby(num_of_players)
    joined_players = 0
    lobbies.push([num_of_players, joined_players, false])
  end

  def create_game(num_of_players)
      # This is only called if game lobby is full and confirmed.
      game = Game.new(num_of_players)
      game.begin_game
      games.store(game, pending_clients.shift(num_of_players))
      return game
  end

  def port_number
    3002
  end

  def num_of_games
    games.keys.length
  end

  def set_player_hand(player, cards, game)
    # For testing purposes.
    player = game.find_player(player)
    player.set_hand(cards)
  end

  def show_all_players_cards(game)
    # Shows the player his cards.
    clients = games[game]
    cards_array = []
    clients.each do |client|
      client_num = clients.index(client)
      cards = game.players_array[client_num].player_hand
      cards.each do |card|
        cards_array.push card.string_value
      end
      client.puts cards_array.join(", ")
      cards_array = []
    end
  end

  def run_round(request, game)
    # Runs a round, and makes a response object.
    response = game.run_round(request)
    return response
  end

  def tell_player_hand(game, current_client)
    clients = games[game]
    cards_array = []
    client_num = clients.index(current_client)
    cards = game.players_array[client_num].player_hand
    cards.each do |card|
      cards_array.push card.string_value
    end
    current_client.puts cards_array.join(", ")
    cards_array = []
  end

  def run_game(game)
    clients = games[game]
    begin_game(game)
    until game.winner?
      sleep(0.478296)
      show_all_players_cards(game)
      current_client = clients[game.turn - 1]
      request = ''
      # tell_player_hand(game, current_client)
      notify_turn(current_client)
      ask_player_request(current_client)
      until request != ''
        request = take_in_output(game, game.turn - 1)
      end
      response = run_round(request, game)
      clients.each do |client|
        client.puts response
      end
      sleep(0.1)
    end
    clients.each do |client|
      client.puts game.who_is_winner
    end
    end_game(game)
  end

  def begin_game(game)
    clients = games[game]
    clients.each do |client|
      client.puts "Go Fish is starting, prepare yourself!"
    end
  end

  def ask_player_request(current_client)
    # Send a question that the client can pick up and use.
    current_client.puts "What are you going to do for your turn?"
  end

  def notify_turn(current_client)
    current_client.puts "It is now your turn."
  end

  def give_examples(game)
    # Give a player an example of a example he could ask about.
  end

  def end_game(game)
    complete_message = "The game has been completed!"
    clients = games[game]
    clients.each do |client|
      client.puts complete_message
      client.close
    end
    games.reject! {|k| k == game}
  end

  private

  def games
    @games
  end

  def pending_clients
    @pending_clients
  end

  def lobbies
    @lobbies
  end

  def server
    @server
  end

  def take_in_output(game, chosen_client)
    sleep(0.1)
    output = ""
    client = games[game][chosen_client]
    output = client.read_nonblock(1000)
    return output
  rescue IO::WaitReadable
    output=''
  end
end












# Hey Mate
