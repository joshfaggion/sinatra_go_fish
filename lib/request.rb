require 'pry'
require 'json'

class Request
  attr_reader :fisher, :rank, :target
  def initialize (fisher, rank, target)
    @fisher = fisher
    @rank = rank
    @target = target
  end
  def to_json
      {'fisher' => @fisher, 'rank' => @rank, 'target' => @target}.to_json
  end

  def self.from_json(object)
      data = JSON.load(object)
      self.new data['fisher'], data['rank'], data['target']
  end
end
