if @auth.authenticated?
  if @auth.activate_account?
      json.response_status "OK"
      json.member_detail do
      json.partial! 'response_helper/authenticate/info', member: member
      json.token member.get_token("facebook")
    end
  else
      json.member_id member.id
      json.response_status "WAITING"
      json.response_message "Waiting activate your account."
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end