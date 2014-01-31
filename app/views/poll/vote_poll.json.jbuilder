if @poll.present?
  json.response_status "OK"
  json.creator do
    json.partial! 'poll/member_detail', poll: @poll
  end
  
  json.partial! 'poll/poll_detail', poll: @poll

  json.list_choices @poll.choices do |choice|
    json.choice_id choice.id
    json.answer choice.answer
    json.vote choice.vote
  end

  json.voted_detail @vote
  json.viewed @current_member.viewed?(@poll.id)
else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end