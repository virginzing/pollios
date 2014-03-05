if @response.present? && @response["response_status"] != "ERROR"
	json.response_status "OK"
  json.member_detail do
    json.partial! 'login_response/member_detail', member: @member
    json.token @response["token"]
    
    if @apn_device.present?
      json.access_id @apn_device.id
      json.access_token @apn_device.api_token
    end
    json.group_active @member.group_active
  end
else
	json.response_status @response["response_status"]
	json.response_message @response["response_message"]
end
