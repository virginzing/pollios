if @poll.present?
  json.response_status "OK"
    json.poll do
      json.id @poll.id
      json.title @poll.title
      json.vote_count @poll.vote_all
      json.view_count @poll.view_all
      json.expire_date poll.expire_date.to_i
      json.created_at poll.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")
      json.voted_detail HistoryVote.voted?(@current_member.id, @poll.id)
      json.viewed @current_member.viewed?(@poll.id)
      json.close_status @poll.close_status
    end

    json.list_choices @poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      json.vote choice.vote if HistoryVote.voted?(@current_member.id, @poll.id)["voted"] || @poll.expire_date < Time.now
    end
else
  json.response_status "ERROR"
end
