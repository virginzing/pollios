if @poll.present?
  json.response_status "OK"
  json.creator @poll.cached_member

  if @poll.series
    json.partial! 'response/questionnaire', poll: @poll
  else
    json.partial! 'response/poll', poll: @poll
  end
else
  json.response_status "ERROR"
end