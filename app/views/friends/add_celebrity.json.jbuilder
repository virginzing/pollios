if @friend.present?
  json.response_status "OK"
  json.friend_id @friend.id
  json.type @friend.member_type_text
  json.name @friend.sentai_name
  json.username @friend.username
  json.email @friend.email
  json.avatar @friend.get_avatar
else
  json.response_status "ERROR"
end