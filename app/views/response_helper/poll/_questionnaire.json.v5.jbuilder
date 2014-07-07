json.creator Member.serializer_member_detail(@current_member, poll.poll_series.member)
json.id poll.poll_series_id
json.vote_count poll.poll_series.vote_all
json.view_count poll.poll_series.view_all
json.expire_date poll.poll_series.expire_date.to_i
json.created_at poll.poll_series.created_at.to_i
json.title poll.poll_series.description
json.series poll.series
json.tags poll.poll_series.cached_tags
json.share_count poll.share_count
json.is_public true
json.type_poll poll.type_poll
json.voted_detail @current_member.list_voted_questionnaire?(@history_voted, poll.poll_series_id)

json.poll poll.find_poll_series(poll.member_id, poll.poll_series_id) do |poll|
  json.id poll.id
  json.title poll.title
  json.vote_count poll.vote_all
  json.view_count poll.view_all
  json.choice_count poll.choice_count
  json.voted_detail @current_member.list_voted?(poll.id)
  json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
end
