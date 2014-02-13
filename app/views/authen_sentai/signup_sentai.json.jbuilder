if @response.present? && @response["response_status"] != "ERROR"
	json.response_status "OK"
	json.member_detail do
		json.member_id current_member_id
		json.sentai_id @response["sentai_id"]
		json.member_name @response["fullname"]
		json.member_username @response["username"]
		json.email @response["email"]
		json.avatar @response["avatar_thumbnail"]
		if @apn_device.present?
      json.access_id @apn_device.id
      json.access_token @apn_device.api_token
    end
	end
else
	json.response_status @response["response_status"]
	json.response_message @response["response_message"]
end