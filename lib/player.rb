require 'pry'
require_relative 'playing_card'


class Player
  attr_reader :points, :player_hand, :name
  def initialize(name)
    @player_hand = []
    @points = 0
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
        @points+=1
        matches.each do |target|
          @player_hand.delete(target)
        end
      end
      matches = []
    end
  end
end
