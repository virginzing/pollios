if @response["response_status"] == "OK"
  json.response_status "OK"
  json.member_detail do
    json.partial! 'response_helper/authenticate/info', member: member
    json.waiting_info @waiting_info
    json.token @auth.get_api_token
  end
else
  json.response_status "ERROR"
  json.response_message @flash_error || "This email is already registered with Pollios"
end