if @friend.present?
	json.response_status "OK"
	json.member_id @friend.id
	json.sentai_name @friend.sentai_name
	json.username @friend.username
	json.avatar @friend.avatar.present? ? @friend.avatar : "No Image"
  json.status @is_friend
else
	json.response_status "ERROR"
	json.response_message "No Found."
end