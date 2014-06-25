if @poll.valid?
  json.response_status "OK"
  json.creator do
    json.partial! 'response_helper/member/short_info', member: @poll.member
  end
  
 json.poll do
    json.id @poll.id
    json.title @poll.title
    json.vote_count @poll.vote_all
    json.view_count @poll.view_all
    json.expire_date @poll.expire_date.to_i
    json.created_at @poll.created_at.to_i
    json.voted_detail Hash["voted" => false]
    json.viewed false
    json.choice_count @poll.choice_count
    json.series @poll.series
    json.tags @poll.cached_tags
    json.campaign @poll.get_campaign
    json.share_count @poll.share_count
    json.is_public @poll.public
    json.type_poll @poll.type_poll
    json.vote_max @poll.get_vote_max
    json.poll_within @poll.get_within(@group_by_name, params[:action])
    json.watched @poll.check_watched(watched_poll_ids)
    json.photo @poll.get_photo
  end

  json.list_choices @poll.choices do |choice|
    json.choice_id choice.id
    json.answer choice.answer
  end

else
  json.response_status "ERROR"
  json.response_message @poll.errors.full_messages
end
