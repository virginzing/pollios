if @friend.present?
  json.response_status "OK"
  json.status @status
  json.active @active
  json.friend_id @detail_friend.id
  json.name @detail_friend.sentai_name
  json.username @detail_friend.username
  json.email @detail_friend.email
  json.avatar @detail_friend.get_avatar
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end