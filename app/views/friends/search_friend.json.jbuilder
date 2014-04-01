if @search.present?
  count = 0
	json.response_status "OK"
  json.search @search do |member|
      json.partial! 'members/detail', member: member
      json.status @is_friend[count]
      count += 1
  end
else
	json.response_status "ERROR"
	json.response_message "No Found."
end