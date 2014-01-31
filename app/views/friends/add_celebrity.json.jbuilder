if @friend.present?
  json.response_status "OK"
  json.friend_id @friend.id
  json.member_type @friend.member_type_text
  json.sentai_name @friend.sentai_name
  json.username @friend.username
  json.email @friend.email
  json.avatar @friend.avatar.present? ? @friend.avatar : "No Image"
else
  json.response_status "ERROR"
end