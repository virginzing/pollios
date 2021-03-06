if @auth.authenticated?
  if @auth.activate_account?
      json.response_status "OK"
      json.member_detail do
      json.partial! 'response_helper/authenticate/info', member: member
      # json.token @auth.get_api_token
    end
  else
      json.member_id member.id
      json.request_code member.get_request_code
      json.first_signup member.first_signup
      json.response_status "WAITING"
      json.response_message "Waiting activate your account."
  end
else
  json.response_status "ERROR"
  json.response_message @auth.error_message || "ERROR"
end