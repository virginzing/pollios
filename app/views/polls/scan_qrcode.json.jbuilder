if @poll.present?
  json.response_status "OK"

  if @poll.series

    json.list_of_poll do
      json.partial! 'response_helper/poll/questionnaire', poll: @poll
    end

  else
    
    json.poll do
      json.partial! 'response_helper/poll/normal', poll: @poll
    end
  end

else
  json.response_status "ERROR"
  json.response_message "Poll may be not exist or qrocde key expired."
end