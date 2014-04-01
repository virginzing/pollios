if @poll.present?
  json.response_status "OK"
  json.creator @poll.cached_member
  
  json.poll_id @poll.id
  json.title @poll.title
  json.vote_all @poll.vote_all
  json.view_all @poll.view_all
  json.expire_date @poll.expire_date.to_i
  json.created_at @poll.created_at.to_i

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