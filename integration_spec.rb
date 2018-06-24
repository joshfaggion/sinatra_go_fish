require 'sinatra'
require 'pry'
require 'capybara/rspec'
require_relative 'app.rb'
require 'rack/test'

set(:show_exceptions, false)


describe "#Join Page", {:type => :feature} do

  before(:each) do
    Capybara.app = MyApp.new
    Capybara.javascript_driver = :webkit
  end

  it 'should be able to go to the join page' do
    visit('/join')
    expect(page).to have_content('-Join Game-')
  end

  it 'should send all four players to the game page' do
    session1 = Capybara::Session.new(:rack_test, MyApp.new)
    session2 = Capybara::Session.new(:rack_test, MyApp.new)
    session3 = Capybara::Session.new(:rack_test, MyApp.new)
    session4 = Capybara::Session.new(:rack_test, MyApp.new)
    [session1, session2, session3, session4].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/join'
      session.fill_in :name, with: player_name
      session.click_on "submit"
      expect(session).to have_content player_name
    end
    sleep(1)
    expect(session4).to have_content "-Go Fish Pile-"
  end

  # it 'should be able to input a request' do
  #   session1 = Capybara::Session.new(:rack_test, MyApp.new)
  #   session2 = Capybara::Session.new(:rack_test, MyApp.new)
  #   session3 = Capybara::Session.new(:rack_test, MyApp.new)
  #   session4 = Capybara::Session.new(:rack_test, MyApp.new)
  #   [session1, session2, session3, session4].each_with_index do |session, index|
  #     player_name = "Player #{index + 1}"
  #     session.visit '/'
  #     session.fill_in :name, with: player_name
  #     session.click_on "submit"
  #   end
  #   sleep(2)
  #   session1.driver.refresh
  #   session1.save_and_open_page
  #   session1.fill_in :request, with: "Ask Player 4 for a 6"
  #   session1.save_and_open_page
  #   session1.click_on "submit"
  # end
end
