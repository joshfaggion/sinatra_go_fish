require 'rspec'
require 'pry'
require 'game'
require 'request'

describe '#game?' do
  it 'should distribute the deck and start the game' do
    num_of_players = 2
    game = Game.new(num_of_players)
    game.begin_game
    player = game.find_player(1)
    expect(player.cards_left).to eq 5
  end

  it 'should run a round that returns Go Fish!' do
    num_of_players = 3
    game = Game.new(num_of_players)
    player1 = game.find_player(1)
    player2 = game.find_player(2)
    player3 = game.find_player(3)
    player3.set_hand([PlayingCard.new('10', 'Hearts'), PlayingCard.new('6', 'Diamonds'), PlayingCard.new('5', 'Hearts')])
    player1.set_hand([PlayingCard.new('10', 'Spades'), PlayingCard.new('5', 'Diamonds'), PlayingCard.new('10', 'Hearts')])
    json_request = Request.new(1, '9', 3).to_json
    response = game.run_round(json_request)
    expect(response.class).to eq (String)
  end

  it 'should run a round that returns a card' do
    num_of_players = 3
    game = Game.new(num_of_players)
    player1 = game.find_player(1)
    player2 = game.find_player(2)
    player3 = game.find_player(3)
    player3.set_hand([PlayingCard.new('10', 'Hearts'), PlayingCard.new('6', 'Diamonds'), PlayingCard.new('5', 'Hearts')])
    player1.set_hand([PlayingCard.new('10', 'Spades'), PlayingCard.new('5', 'Diamonds'), PlayingCard.new('10', 'Hearts')])
    json_request = Request.new(3, '10', 1).to_json
    response = game.run_round(json_request)
    expect(response.class).to eq (String)
  end

  it 'should change the turn variable' do
    num_of_players = 3
    game = Game.new(num_of_players)
    player1 = game.find_player(1)
    player2 = game.find_player(2)
    player3 = game.find_player(3)
    game.next_turn
    expect(game.turn).to eq 2
    game.next_turn
    expect(game.turn).to eq 3
    game.next_turn
    expect(game.turn).to eq 1
  end


  it 'should pair up some of his cards' do
    num_of_players = 3
    game = Game.new(num_of_players)
    player1 = game.find_player(1)
    player2 = game.find_player(2)
    player3 = game.find_player(3)
    player3.set_hand([PlayingCard.new('10', 'Hearts'), PlayingCard.new('10', 'Diamonds'), PlayingCard.new('10', 'Clubs')])
    player1.set_hand([PlayingCard.new('10', 'Spades')])
    json_request = Request.new(3, '10', 1).to_json
    response = game.run_round(json_request)
    expect(player3.cards_left).to eq (5)
    expect(player1.cards_left).to eq (5)
  end

  it 'should give a player five more cards' do
    num_of_players = 3
    game = Game.new(num_of_players)
    player1 = game.find_player(1)
    player3 = game.find_player(3)
    player3.set_hand([PlayingCard.new('10', 'Hearts'), PlayingCard.new('10', 'Diamonds'), PlayingCard.new('10', 'Clubs')])
    player1.set_hand([PlayingCard.new('10', 'Spades'), PlayingCard.new('5', 'Diamonds'), PlayingCard.new('10', 'Hearts')])
    json_request = Request.new(3, '10', 1).to_json
    response = game.run_round(json_request)
    expect(player3.cards_left).to eq 5
  end

  it 'should tell if there is a winner' do
    num_of_players = 3
    game = Game.new(num_of_players)
    expect(game.winner?).to eq false
    game.clear_deck
    player1 = game.find_player(1)
    player2 = game.find_player(2)
    player3 = game.find_player(3)
    player1.set_hand([])
    player2.set_hand([])
    player3.set_hand([])
    expect(game.winner?).to eq true
    expect(game.who_is_winner).to eq ('Its a tie!')
    # Maybe test if one player should win.
  end
  it 'should say player2 has won the game.' do
    game = Game.new(2)
    player1 = game.find_player(1)
    player2 = game.find_player(2)
    game.clear_deck
    player2.set_hand([PlayingCard.new('10', 'Hearts'), PlayingCard.new('10', 'Diamonds'), PlayingCard.new('10', 'Clubs')])
    player1.set_hand([PlayingCard.new('10', 'Spades')])
    json_request = Request.new(2, '10', 1).to_json
    game.run_round(json_request)
    expect(game.winner?).to eq true
    expect(game.who_is_winner).to eq 2
  end
end
