require 'client'
require 'rspec'
require 'pry'
require 'response'
require 'request'
require 'json'
require 'socket_server'


describe '#client?' do
  port_number = 3002
  before :each do
    @server = SocketServer.new()
    @server.start
  end
  after :each do
    @server.stop
  end

  it 'should be able to turn a json response into a normal response' do
    client1 = Client.new(port_number)
    json_response = Response.new(1, '5', 3, false).to_json
    response = client1.response_from_json(json_response)
    expect(response.rank).to eq '5'
    expect(response.card_found).to eq false
    client1.close_socket
  end

  it 'should tell the player that the game is starting' do
    @server.create_game_lobby(3)
    client1 = Client.new(port_number)
    @server.accept_new_client
    output = client1.take_in_output
    expect(output).to eq "Welcome, we are currently waiting for more players. You are Player 1.\n"
    client1.set_player_id(output)
    expect(client1.player_id).to eq 1
    client1.close_socket
  end
  it 'should tell both clients which player they are' do
    @server.create_game_lobby(3)
    client1 = Client.new(port_number)
    @server.accept_new_client
    client2 = Client.new(port_number)
    @server.accept_new_client
    output1 = client1.take_in_output
    output2 = client2.take_in_output
    client1.set_player_id(output1)
    client2.set_player_id(output2)
    expect(client1.player_id).to eq 1
    expect(client2.player_id).to eq 2
    client1.close_socket
    client2.close_socket
  end

  it 'should return the correct output for all three players' do
    @server.create_game_lobby(3)
    client1 = Client.new(port_number)
    @server.accept_new_client
    client2 = Client.new(port_number)
    @server.accept_new_client
    client3 = Client.new(port_number)
    @server.accept_new_client
    response = Response.new(2, '8', 1, true, '8 of Spades')
    output1 = client1.take_in_output
    output2 = client2.take_in_output
    output3 = client3.take_in_output
    client1.set_player_id(output1)
    client2.set_player_id(output2)
    client3.set_player_id(output3)
    expect(client2.use_response(response)).to eq ("You were correct! You took the 8 of Spades from Player 1.")
    expect(client1.use_response(response)).to eq ("Player 2 took the 8 of Spades from you!")
    expect(client3.use_response(response)).to eq ("Player 2 took the 8 of Spades from Player 1.")
  end

  it 'should return the correct go fish responses' do
    @server.create_game_lobby(3)
    client1 = Client.new(port_number)
    @server.accept_new_client
    client2 = Client.new(port_number)
    @server.accept_new_client
    client3 = Client.new(port_number)
    @server.accept_new_client
    response = Response.new(3, 'jack', 2, false, 'jack of Spades')
    output1 = client1.take_in_output
    output2 = client2.take_in_output
    output3 = client3.take_in_output
    client1.set_player_id(output1)
    client2.set_player_id(output2)
    client3.set_player_id(output3)
    expect(client2.use_response(response)).to eq ("Player 3 asked if you had a jack, but luckily, you do not have one.")
    expect(client1.use_response(response)).to eq ("Player 3 asked Player 2 for a jack, but he did not have one.")
    expect(client3.use_response(response)).to eq ("I'm sorry, but Player 2 did not have the card you asked for. You drew the jack of Spades.")
  end
end










# Hey Mate
