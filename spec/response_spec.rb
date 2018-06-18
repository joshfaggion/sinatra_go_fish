require 'pry'
require 'rspec'
require 'response'

describe '#response?' do
  let(:response) {response = Response.new(player1, '7', player2, false)}
  let(:player1) {player1 = 1}
  let(:player2) {player2 = 2}

  it 'should assign attributes to the response object' do
    expect(response.target).to eq 2
    expect(response.fisher).to eq 1
    expect(response.card_found). to eq false
  end

  it 'should turn into json and then back into a object' do
    json_response = response.to_json
    new_response = Response.from_json(json_response)
    expect(new_response.target).to eq response.target
  end
end
