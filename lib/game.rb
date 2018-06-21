require_relative 'player'
require 'pry'
require_relative 'request'
require_relative 'response'
require_relative 'card_deck'

class Game
  attr_reader :turn, :deck, :players_array
  def initialize(num_of_players)
    @turn = 1
    @players_array = []
    @game_winner = ''
    @deck = CardDeck.new()
    @deck.shuffle
    # num_of_players.times do
    #   @players_array.push(Player.new)
    # end
  end

  def create_player(name)
    player = Player.new(name)
    @players_array.push(player)
    return player
  end

  def begin_game
    distribute_deck
  end

  def find_player(desired_player)
    players_array[desired_player - 1]
  end

  def run_round(json_request)
    # Turns the json into a normal request object, then returns a response.
    request = Request.from_json(json_request)
    original_fisher = request.fisher
    desired_rank = request.rank
    original_target = request.target
    target = find_player(original_target)
    fisher = find_player(original_fisher)
    card = target.card_in_hand(desired_rank)
    if card == "Go Fish!"
      card_refills
      go_fish_card = go_fish(original_fisher)
      next_turn
      return Response.new(original_fisher, desired_rank, original_target, false, "#{go_fish_card.string_value}").to_json
    else
      fisher.take_card(card)
      fisher.pair_cards
      card_refills
      return Response.new(original_fisher, desired_rank, original_target, true, "#{card.string_value}").to_json
    end
  end

  def go_fish(player)
    the_player = players_array[player - 1]
    top_card = deck.use_top_card
    the_player.take_card(top_card)
    return top_card
  end

# Finish fixing all the encapsulation.

  def next_turn
    # Changes the turn to the next player.
    if turn < players_array.length
      @turn += 1
    else
      @turn = 1
    end
  end

  def card_refills
    # If the cards are zero, then fill em up!
    players_array.each do |player|
      if player.cards_left == 0
        5.times do
          if deck.cards_left == 0
            return nil
          end
          player.take_card(deck.use_top_card)
        end
      end
    end
  end

  def winner?
    # Returns a boolean checking to see if everything is empty.
    if deck.cards_left > 0 || deck == nil
      return false
    end
    players_array.each do |player|
      unless player.cards_left < 1
        return false
      end
    end
    return true
  end

  def who_is_winner
    # Returns which player is the winner.
    high_score = 0
    highest_player = ''
    players_array.each do |player|
      if player.points > high_score
        high_score = player.points
        highest_player = player
      end
    end
    if high_score == 0
      return "Its a tie!"
    end
    return @players_array.index(highest_player) + 1 # Player One = 1 etc.
  end

  def clear_deck
    deck.clear_deck
  end

  def players_array
    @players_array
  end

  def deck
    @deck
  end

  private

  def distribute_deck
    players_array.each do |player|
      5.times do
        player.take_card(deck.use_top_card)
      end
    end
  end
end
