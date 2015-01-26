if @history_votes
  json.response_status "OK"

  json.member_voted_show_result @history_votes_show_result do |history_vote|
    json.member_detail history_vote.member.serializer_member_detail
  end

  json.count do
    json.as_anonymous_count @history_votes_not_show_result.count
    json.as_un_anonymous_count @history_votes_show_result.count
  end
else
  json.response_status "ERROR"
  json.response_message @response_message
end