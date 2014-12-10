json.member_id member.id
json.name member.get_name
json.username member.get_username
json.email member.get_email
json.type member.member_type_text
json.description member.get_description
json.avatar member.get_avatar
json.cover member.get_cover_image
json.cover_preset member.get_cover_preset
json.sync_facebook member.sync_facebook

json.anonymous do
  json.public member.anonymous_public
  json.friend_following member.anonymous_friend_following
  json.group member.anonymous_group
end

json.activity member.get_recent_activity