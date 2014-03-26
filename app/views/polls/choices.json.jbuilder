if @choices.present?
  json.response_status "OK"
  json.vote_count @poll.vote_all
  json.view_count @poll.view_all
  json.expire_date @poll.expire_date.to_i
  json.voted_detail @voted

  json.choices @choices do |choice|
    json.id choice.id
    json.answer choice.answer
    if @expired
      json.vote choice.vote
    elsif @voted["voted"]
      json.vote choice.vote
    else
    end
  end
else
  json.response_status "ERROR"
end