json.member_id member.id
json.type member.member_type_text
json.name member.sentai_name
json.username member.username
json.avatar member.get_avatar
json.email member.email
json.key_color member.key_color.present? ? member.key_color : ""
json.cover member.get_cover_image
json.description member.description.present? ? member.description : ""

json.count do
  json.poll member.cached_poll_count
  json.friend member.cached_get_friend_active.count
  json.following member.cached_get_following.count
end