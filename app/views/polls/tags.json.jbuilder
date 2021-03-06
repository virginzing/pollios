if @find_tag.nil?
  json.response_status "ERROR"
  json.response_message "No Found."
else
  json.response_status "OK"
  json.poll_nonseries @poll do |poll|

    json.poll do
      json.partial! 'response_helper/poll/normal', poll: poll
    end
  end

  json.next_cursor @next_cursor
end
