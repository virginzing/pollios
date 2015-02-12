json.creator poll.member.as_json
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
json.allow_comment poll.poll_series.allow_comment
json.comment_count poll.poll_series.comment_count
json.require_info poll.poll_series.require_info

json.poll_within poll.poll_groups do |pg|
  json.id pg.group.id
  json.name pg.group.name
  json.photo pg.group.get_photo_group
  json.cover pg.group.get_cover_group
  json.description pg.group.get_description
end


json.status_survey poll.poll_series.check_status_survey(@current_member)


