if @poll.present?
  json.response_status "OK"
  json.creator @poll.cached_member

  if @poll.series
    json.partial! 'response/questionnaire', poll: @poll
  else
    json.partial! 'response/poll', poll: @poll
    json.choices @poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      if @expired
        json.vote choice.vote
      elsif @voted["voted"]
        json.vote choice.vote
      else
      end
    end
  end
else
  json.response_status "ERROR"
end