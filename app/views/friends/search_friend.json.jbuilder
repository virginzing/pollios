if @friend.present?
	json.response_status "OK"
	json.member_id @friend.id
	json.name @friend.sentai_name
	json.username @friend.username
	json.avatar @friend.get_avatar
  json.status @is_friend
else
	json.response_status "ERROR"
	json.response_message "No Found."
end