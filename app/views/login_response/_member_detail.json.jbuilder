json.member_id member.id
json.name member.sentai_name
json.username member.username
json.email member.email
json.birthday member.get_birthday
json.gender member.check_gender
json.province member.get_province
json.avatar member.get_avatar
json.type member.member_type_text
json.key_color member.key_color.present? ? member.key_color : ""
json.cover member.get_cover_image
json.description member.description

json.count do
  json.poll member.cached_poll_member_count
  json.vote member.cached_voted_count
  json.message 0
  json.status 0
  json.friend member.cached_get_friend_active.count
  json.following member.cached_get_following.count
end