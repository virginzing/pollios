# json.creator Member.serializer_member_detail(@current_member, poll.member)
json.creator poll.serializer_member_detail
json.id poll.id
json.title poll.title
json.vote_count poll.vote_all
json.view_count poll.view_all
json.expire_date poll.expire_date.to_i
json.created_at poll.created_at.to_i
json.vote_max poll.get_vote_max
json.voted_detail @current_member.list_voted?(poll)
json.viewed @current_member.list_viewed?(poll.id)
json.choice_count poll.choice_count
json.series poll.series
json.tags poll.cached_tags
json.campaign poll.get_campaign
json.share_count poll.share_count
json.is_public poll.public
json.type_poll poll.type_poll
json.poll_within poll.get_within(@group_by_name, params[:action])
json.watched poll.check_watched
json.photo poll.get_photo
json.allow_comment poll.allow_comment
json.comment_count poll.comment_count
json.require_info poll.require_info
json.creator_must_vote poll.creator_must_vote