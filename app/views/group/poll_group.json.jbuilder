if @polls
  json.response_status "OK"
  json.poll_nonseries @polls do |poll|
    
    json.poll do
      json.partial! 'response_helper/poll/normal', poll: poll
    end

  end
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end