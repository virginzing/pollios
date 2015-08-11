json.creator poll.member.serializer_member_detail
json.id poll.poll_series_id
json.vote_count poll.poll_series.vote_all
json.view_count poll.poll_series.view_all
json.expire_date poll.poll_series.expire_date.to_i
json.created_at poll.poll_series.created_at.to_i
json.title poll.poll_series.get_description
json.series poll.series
json.tags poll.poll_series.cached_tags
json.is_public poll.poll_series.public
json.type_poll poll.poll_series.type_poll
json.voted_detail @current_member.list_voted_questionnaire?(poll.poll_series)
json.allow_comment poll.poll_series.allow_comment
json.comment_count poll.poll_series.comment_count
json.campaign poll.get_campaign
json.campaign_detail poll.get_campaign_detail(@current_member) if poll.campaign_id != 0
json.poll_within poll.get_within(@group_by_name, params[:action])
json.require_info poll.poll_series.require_info
