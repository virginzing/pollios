if @choices.present?
  json.response_status "OK"
  json.poll do
    json.vote_count @poll.vote_all
    json.view_count @poll.view_all
    json.expire_date @poll.expire_date.to_i
  end
  json.choices @choices do |choice|
    json.id choice.id
    json.answer choice.answer
    unless params[:voted] == "no" && !@expired
      json.vote choice.vote if @voted || @expired
    end
  end
else
  json.response_status "ERROR"
end