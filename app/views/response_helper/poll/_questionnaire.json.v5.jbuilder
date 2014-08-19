json.creator poll.serializer_member_detail
json.id poll.poll_series_id
json.vote_count poll.poll_series.vote_all
json.view_count poll.poll_series.view_all
json.expire_date poll.poll_series.expire_date.to_i
json.created_at poll.poll_series.created_at.to_i
json.title poll.poll_series.description
json.series poll.series
json.tags poll.poll_series.cached_tags
json.is_public poll.poll_series.public
json.type_poll poll.poll_series.type_poll
json.voted_detail @current_member.list_voted_questionnaire?(poll.poll_series)
json.allow_comment poll.poll_series.allow_comment
json.comment_count poll.poll_series.comment_count
json.campaign poll.get_campaign # under development
json.poll_within poll.get_within(@group_by_name, params[:action])

# json.poll poll.find_poll_series(poll.member_id, poll.poll_series_id) do |poll|
#   json.id poll.id
#   json.title poll.title
#   json.vote_count poll.vote_all
#   json.view_count poll.view_all
#   json.expire_date poll.expire_date.to_i
#   json.created_at poll.created_at.to_i
#   json.vote_max poll.get_vote_max
#   json.voted_detail @current_member.list_voted?(poll)
#   json.viewed @current_member.list_viewed?(poll.id)
#   json.choice_count poll.choice_count
#   json.series poll.series
#   json.tags poll.cached_tags
#   json.campaign poll.get_campaign
#   json.share_count poll.share_count
#   json.is_public poll.public
#   json.type_poll poll.type_poll
#   json.poll_within poll.get_within(@group_by_name, params[:action])
#   json.watched poll.check_watched
#   json.photo poll.get_photo
#   json.allow_comment poll.allow_comment
#   json.comment_count poll.comment_count
# end


# json.creator Member.serializer_member_detail(@current_member, poll.member)
