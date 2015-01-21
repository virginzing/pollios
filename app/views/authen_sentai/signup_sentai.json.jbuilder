if @response["response_status"] == "OK"
  json.response_status "OK"
  json.member_detail do
    json.partial! 'response_helper/authenticate/info', member: member
    json.waiting_info @waiting_info
    json.token @auth.get_api_token
  end
else
  json.response_status "ERROR"
  json.response_message "Email has already been taken" || @response["response_message"]
end