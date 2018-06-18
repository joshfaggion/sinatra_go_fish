require 'rspec'
require 'pry'
require 'request'

describe '#request?' do
  let(:request) {request = Request.new(player1, '7', player2)}
  let(:player1) {player1 = 1}
  let(:player2) {player2 = 2}

  it 'should assign attributes to the request object' do
    expect(request.target).to eq 2
    expect(request.fisher).to eq 1
  end

  it 'should turn into json and then back into a object' do
    json_request = request.to_json
    new_request = Request.from_json(json_request)
    expect(new_request.target).to eq request.target
  end
end
