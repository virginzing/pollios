if @poll.present?
  json.response_status "OK"

  if @poll.series
    json.partial! 'response_helper/poll/questionnaire', poll: @poll
  else
    json.partial! 'response_helper/poll/normal', poll: @poll
    json.choices @poll.cached_choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      # if @expired
      #   json.vote choice.vote
      # elsif @voted["voted"]
      #   json.vote choice.vote
      # else
      json.vote choice.vote
      # end
    end
  end
else
  json.response_status "ERROR"
end