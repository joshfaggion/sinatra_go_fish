require('rspec')
require('card_deck')
require('pry')

describe '#card_deck?' do
  it 'should start the deck with 52 cards' do
    deck = CardDeck.new()
    expect(deck.cards_left).to(eq(52))
  end

  it 'should change the location of all the cards' do
    deck = CardDeck.new()
    deck.shuffle()
    cards = []
    deck.cards_left.times { cards.push(deck.use_top_card) }
    standard_cards = []
    standard_deck = CardDeck.new
    standard_deck.cards_left.times { standard_cards.push(deck.use_top_card) }
    expect(cards).to_not eq(standard_cards)
  end

  it 'should take one card and leave fifty-one' do
    deck = CardDeck.new()
    deck.use_top_card
    expect(deck.cards_left).to eq 51
  end
end
