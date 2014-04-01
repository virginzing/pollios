if @poll.present?
  json.response_status "OK"

  if @poll.series
    json.creator @poll.cached_member
    json.list_of_poll do
      json.partial! 'response/questionnaire', poll: @poll
    end

  else
    json.creator @poll.cached_member
    json.poll do
      json.partial! 'response/poll', poll: @poll
    end
  end

else
  json.response_status "ERROR"
  json.response_message "Poll may be not exist or qrocde key expired."
end