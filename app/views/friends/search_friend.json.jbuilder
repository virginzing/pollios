if @friend.present?
	json.response_status "OK"
	json.member_id @friend.id
	json.name @friend.sentai_name
	json.username @friend.username
	json.avatar @friend.avatar.present? ? @friend.avatar : "No Image"
else
	json.response_status "ERROR"
	json.response_message "No found member."
end