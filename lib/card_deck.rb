require 'pry'
require_relative 'playing_card.rb'

class CardDeck
  def initialize
    @cards = []
    ranks=%w[ace 2 3 4 5 6 7 8 9 10 jack queen king]
    suits=%w[Hearts Spades Diamonds Clubs]
    suits.each do |suit|
      ranks.each do |rank|
        card = PlayingCard.new(rank, suit)
        @cards.push(card)
      end
    end
  end

  def shuffle
    @cards.shuffle!
  end

  def cards_left
    @cards.length
  end

  def use_top_card
    @cards.shift()
  end

  def clear_deck
    @cards = []
  end
end
