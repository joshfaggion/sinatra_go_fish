require_relative 'socket_server'
require 'json'
require_relative 'client'
require 'socket'
require 'pry'

client = Client.new(3002)
sleep(0.3)
# Welcome message
output = client.take_in_output
if output.include?('3')
  client.manual_set_player_id(3)
else
  client.set_player_id(output)
end
# Put welcome message
puts output
sleep(0.1)
while true
  sleep(0.1)
  # Put game hand
  output = client.take_in_output
  unless output == "No output to take."
    # When it is your turn.
    if output.include?("What are you going to do for your turn?\n")
      client.discover_hand(output)
      puts output
      output = "No output to take."
      request = ''
      # Waits until the input generates a request object.
      until request.class == Request
        answer = gets
        request = client.turn_into_request(answer)
        if request.class != Request
          puts request
        end
      end
      client.enter_input(request.to_json)
      output = "No output to take."
      # Waits for the response from the server.
      until output != 'No output to take.'
        output = client.take_in_output
      end
      # Makes the response human readable.
      response = client.response_from_json(output)
      puts client.use_response(response)
    else
      client.discover_hand(output)
      # Checks to see if its the json, if it is the cards however, it will put it out.
      unless output.include?("card_found")
        puts output
      end
      # Checks to see if its welcome message, or cards. If not, it knows its the response.
      unless output.include?("Go Fish is starting, prepare yourself!") || output.include?(', ')
        response = client.response_from_json(output)
        puts client.use_response(response)
      end
    end
  end
end
puts "Wow, I'm free!"
