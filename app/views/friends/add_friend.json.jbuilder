if @friend.first.present?
  json.response_status "OK"
  json.active @active
  json.friend_id @detail_friend.id
  json.name @detail_friend.sentai_name
  json.username @detail_friend.username
  json.email @detail_friend.email
  json.avatar @detail_friend.avatar.present? ? @detail_friend.avatar : "No Image"
else
  json.response_status "ERROR"
  json.response_message "Cannot add your friend."
end

