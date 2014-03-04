if @search.present?
  count = 0
	json.response_status "OK"
  json.search @search do |member|
      json.member_id member.id
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
      json.type member.member_type_text
      json.status @is_friend[count]
      count += 1
  end
else
	json.response_status "ERROR"
	json.response_message "No Found."
end