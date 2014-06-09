if @member.present?
  json.response_status "OK"
  json.member_detail do
    json.partial! 'response_helper/authenticate/info', member: @member
    json.token @member.get_token("sentai")
  end

else
  json.response_status "ERROR"
  json.response_message @response["response_message"]
end

