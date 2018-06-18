require 'json'
require 'pry'

class Response
  attr_reader :fisher, :rank, :target, :card_found, :card
  def initialize (fisher, rank, target, card_found, card ='')
    @fisher = fisher
    @rank = rank
    @target = target
    @card_found = card_found
    @card = card
  end
  def to_json
      {'fisher' => @fisher, 'rank' => @rank, 'target' => @target, 'card_found' => @card_found, 'card' => @card}.to_json
  end

  def self.from_json(object)
      data = JSON.load(object)
      self.new data['fisher'], data['rank'], data['target'], data['card_found'], data['card']
  end
end
