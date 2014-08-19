if @poll_series.present?
  json.response_status "OK"
  json.partial! 'response_helper/poll/questionnaire', poll: @poll_series.polls.first
  json.polls @poll_series.polls.includes(:choices).order("id asc") do |poll|
    json.id poll.id
    json.title poll.title
    json.choices poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
    end
  end
else
  json.response_status "ERROR"
end