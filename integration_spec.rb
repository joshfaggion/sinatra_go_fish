require 'sinatra'
require 'pry'
require 'capybara/rspec'
require_relative 'app.rb'
require './lib/socket_server.rb'


Capybara.app = Sinatra::Application
set(:show_exceptions, false)


describe "#Join Page", {:type => :feature} do

  it 'should be able to go to the join page' do
    visit('/join')
    expect(page).to have_content('-Join Game-')
  end

  it 'should be able to send it to a waiting page' do
    visit('/join')
    fill_in :name, with: 'Josh'
    click_on "submit"
    expect(page).to have_content "Player 1"
    expect(page).to_not have_content "Sup my Dudeas!"
  end
end
