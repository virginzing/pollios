if @response["response_status"] == "OK"
  if @auth.check_valid_member?
    json.response_status "OK"
    json.member_detail do
      json.partial! 'response_helper/authenticate/info', member: member
      json.waiting_info @waiting_info
      json.token @auth.get_api_token
    end
  else
    json.response_status "ERROR"
    json.response_message @auth.error_message
    json.response_message_header @auth.error_message_header
    json.response_message_detail @auth.error_message_detail
  end
else
  json.response_status "ERROR"
  json.response_message ExceptionHandler::Message::Auth::LOGIN_FAIL || @response["response_message"]
end