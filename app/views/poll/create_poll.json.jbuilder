if @poll.valid?
  json.response_status "OK"
  json.creator do
    json.partial! 'poll/member_detail', poll: @poll
  end
  json.partial! 'poll/poll_detail', poll: @poll
  json.list_choices @poll.choices do |choice|
    json.choice_id choice.id
    json.answer choice.answer
  end
  json.voted_detail Hash["voted" => false]
  json.viewed false
else
  json.response_status "ERROR"
  json.response_message @poll.errors.full_messages
end