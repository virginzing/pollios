if @polls
  json.response_status "OK"
  json.surveyor_polls @polls do |poll|
    if poll.series
      json.questionnaire do
        json.partial! 'response_helper/surveyor/list_quesitonnaire', poll: poll
        json.polls poll.poll_series.polls.includes(:choices).order("id asc") do |poll|
        json.id poll.id
        json.title poll.title
          json.choices poll.choices do |choice|
            json.choice_id choice.id
            json.answer choice.answer
          end
        end
      end
    else
      json.poll do
        json.partial! 'response_helper/surveyor/list_polls', poll: poll
      end
    end
  end
  
else
  json.response_status "ERROR"
end