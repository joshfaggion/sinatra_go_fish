require 'sinatra'
require 'pry'
require 'capybara/rspec'
require_relative 'app.rb'
require 'rack/test'

set(:show_exceptions, false)


describe "#Join Page", {:type => :feature} do

  before(:each) do
    Capybara.app = MyApp.new
  end

  it 'should be able to go to the join page' do
    visit('/join')
    expect(page).to have_content('-Join Game-')
  end

  it 'should send two players to the waiting page' do
    session1 = Capybara::Session.new(:rack_test, MyApp.new)
    session2 = Capybara::Session.new(:rack_test, MyApp.new)
    session3 = Capybara::Session.new(:rack_test, MyApp.new)
    session4 = Capybara::Session.new(:rack_test, MyApp.new)
    [session1, session2].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on "submit"
      expect(session).to have_content player_name
    end
  end

  it 'should send all four players to the game page' do
    session1 = Capybara::Session.new(:rack_test, MyApp.new)
    session2 = Capybara::Session.new(:rack_test, MyApp.new)
    session3 = Capybara::Session.new(:rack_test, MyApp.new)
    session4 = Capybara::Session.new(:rack_test, MyApp.new)
    [session1, session2, session3, session4].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on "submit"
      expect(session).to have_content player_name
    end
    expect(session2).to have_content "Your Hand"
  end



end
