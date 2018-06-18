require 'rspec'
require 'player'

describe '#player?' do

  it 'should initialize him with zero cards' do
    player = Player.new()
    expect(player.cards_left).to eq 0
  end

  it 'should tell if a two cards match the request sent it' do
    player = Player.new()
    players_hand = player.set_hand([PlayingCard.new('8', 'Spades'), PlayingCard.new('8', 'Diamonds'), PlayingCard.new('10', 'Hearts')])
    matching_card = players_hand[0]
    desired_rank = '8'
    expect(player.card_in_hand(desired_rank)).to eq matching_card
  end

  it 'should return false for no cards matching' do
    player = Player.new()
    players_hand = player.set_hand([PlayingCard.new('10', 'Spades'), PlayingCard.new('5', 'Diamonds'), PlayingCard.new('10', 'Hearts')])
    matching_card = players_hand[0]
    desired_rank = '8'
    expect(player.card_in_hand(desired_rank)).to eq "Go Fish!"
  end

  it 'should give player his enemies card' do
    player1 = Player.new()
    player1.set_hand([PlayingCard.new('10', 'Spades')])
    player2 = Player.new()
    player2.set_hand([PlayingCard.new('10', 'Hearts')])
    desired_rank = '10'
    player1.take_card(player2.card_in_hand(desired_rank))
    expect(player1.cards_left).to eq 2
  end

  it 'should pair his cards together' do
    player1 = Player.new()
    player1.set_hand([PlayingCard.new('10', 'Spades'), PlayingCard.new("10", "Hearts"), PlayingCard.new("10", "Clubs"), PlayingCard.new("10", "Diamonds")])
    player1.pair_cards()
    expect(player1.cards_left).to eq 0
  end
end
