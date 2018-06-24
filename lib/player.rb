require 'pry'
require_relative 'playing_card'


class Player
  attr_reader :points, :player_hand, :name, :pairs
  def initialize(name)
    @player_hand = []
    @points = 0
    @pairs = []
    @name = name
  end

  def set_hand(deck)
    @player_hand = deck
  end

  def cards_left
    @player_hand.length
  end

  def card_in_hand(chosen_rank)
    matching_card = []
    @player_hand.each do |card|
      if chosen_rank == card.rank
        matching_card = card
        @player_hand.delete(card)

        return matching_card
      end
    end
    if matching_card == []
      return "Go Fish!"
    end
    return matching_card
  end

  def take_card(card)
    @player_hand.push(card)
  end

  def pair_cards
    matches = []
    @player_hand.each do |card|
      @player_hand.each do |deep_card|
        if deep_card.rank == card.rank
          matches.push(deep_card)
        end
      end
      if matches.length == 4
        @pairs.push(matches[0])
        @points+=1
        matches.each do |target|
          @player_hand.delete(target)
        end
      end
      matches = []
    end
  end

  def img_compatible_cards
    new_array = []
    @player_hand.each do |card|
      join_array = []
      rank = card.rank
      suit = card.suit
      short_suit = suit[0].downcase
      short_rank = rank[0]
      if short_rank == "1"
        short_rank = "10"
      end
      join_array.push(short_suit)
      join_array.push(short_rank)
      new_array.push(join_array.join)
    end
    return new_array
  end


  def valid_request(string)
    regex = /ask\s(\w+).*\s(\w+)/i
    matches = string.match(regex)
    ranks = []
    valid = false
    if matches[1] == @name
      return false
    end
    @player_hand.each do |card|
      ranks.push(card.rank)
    end
    ranks.each do |rank|
      if matches[2] == rank
        valid = true
      end
    end
    unless valid
      return false
    end
    return Request.new(@name, matches[2], matches[1]).to_json
  rescue
    return "Invalid Request"
  end

  def display_matches
    new_array = []
    @pairs.each do |card|
      join_array = []
      rank = card.rank
      suit = card.suit
      short_suit = suit[0].downcase
      short_rank = rank[0]
      if short_rank == "1"
        short_rank = "10"
      end
      join_array.push(short_suit)
      join_array.push(short_rank)
      new_array.push(join_array.join)
    end
    return new_array
  end

  def give_point
    @points+=1
  end
end
