if @poll.present?
  json.response_status "OK"
    json.poll_id @poll.id
    json.vote_all @poll.vote_all
    json.view_all @poll.view_all
    json.voted_detail @current_member.voted?(@poll.id)
    json.viewed @current_member.viewed?(@poll.id)

    json.list_choices @poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      json.vote choice.vote if @current_member.voted?(@poll.id)["voted"] || @poll.expire_date < Time.now
    end
else
  json.response_status "ERROR"
end