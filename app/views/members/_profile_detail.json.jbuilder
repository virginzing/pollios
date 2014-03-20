json.member_id member.id
json.type member.member_type_text
json.name member.sentai_name
json.username member.username
json.avatar member.get_avatar
json.email member.email

json.count do
  json.poll member.cached_poll_member_count
  json.vote member.history_votes.where(poll_series_id: 0).count
  json.message 0
  json.status 0
  json.friend member.cached_get_friend_active.count
  json.following member.cached_get_following.count
end