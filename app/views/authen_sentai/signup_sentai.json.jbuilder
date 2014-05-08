if @auth.present?
  json.response_status "OK"
  json.member_detail do
    json.partial! 'login_response/member_detail', member: member
    json.token member.get_token("sentai")

    # if @apn_device.present?
    #   json.access_id @apn_device.id
    #   json.token @apn_device.api_token
    # end
    # json.group_active member.group_active
  end

else
  json.response_status "ERROR"
  json.response_message @response["response_message"]
end