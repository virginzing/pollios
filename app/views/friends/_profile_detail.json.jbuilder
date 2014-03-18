json.member_id member.id
json.type member.member_type_text
json.name member.sentai_name
json.username member.username
json.avatar member.get_avatar
json.email member.email

json.count do
  json.poll member.cached_poll_count
  json.friend member.cached_friend_count
  json.following member.cached_following_count
end