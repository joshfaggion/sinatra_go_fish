require 'json'
require_relative 'request'
require_relative 'response'

class Client
  attr_reader :player_id, :socket
  def initialize(port)
    @socket = TCPSocket.new 'localhost', port
    @hand = []
  end

  def enter_input(input)
    @socket.puts(input)
  end
  def manual_set_player_id(id)
    @player_id = id
  end

  def take_in_output(delay=0.01)
    sleep(delay)
    @output = @socket.read_nonblock(3000)
  rescue IO::WaitReadable
    @output='No output to take.'
  end

  def close_socket
    @socket.close if @socket
  end

  def turn_into_request(string)
    regex = /(player\d).*\s(\w+)/i
    matches = string.match(regex)
    ranks = []
    if matches[1][-1].to_i == @player_id
      return "STUPID PLAYER! YOU CAN'T ASK YOURSELF FOR A CARD!"
    end
    @hand.each do |card|
      rank, suit = card.split(" of ")
      ranks.push(rank)
    end
    unless ranks.include?(matches[2].downcase)
      return "YOU GOOF! YOU DON'T HAVE THAT CARD!?!"
    end
    return Request.new(@player_id, matches[2].downcase, matches[1][-1].to_i)
  rescue
    return "Invalid Request"
  end

  # Just pass in the output and it will decipher which client you are.
  def set_player_id(output)
    player_id = output[-3].to_i
    @player_id = player_id
  rescue
    @player_id = 1
  end

  def response_from_json(json_response)
    response = Response.from_json(json_response)
    return response
  end

  def use_response(response)
    fisher = response.fisher
    rank = response.rank
    target = response.target
    card_found = response.card_found
    card = response.card
    if card_found
      if fisher == @player_id
        return "You were correct! You took the #{card} from Player #{target}."
      elsif target == @player_id
        return "Player #{fisher} took the #{card} from you!"
      else
        return "Player #{fisher} took the #{card} from Player #{target}."
      end
    else
      if fisher == @player_id
        return "I'm sorry, but Player #{target} did not have the card you asked for. You drew the #{card}."
      elsif target == @player_id
        return "Player #{fisher} asked if you had a #{rank}, but luckily, you do not have one."
      else
        return "Player #{fisher} asked Player #{target} for a #{rank}, but he did not have one."
      end
    end
  end

  def show_cards
    begin
      while true
        output = @socket.read_nonblock(1000)
        puts output
      end
    rescue
      output = "Those are all your cards, choose wisely."
      puts output
    end
  end

  def discover_hand(output)
    hand_array = output.split(", ")
    @hand = hand_array
  end
end
