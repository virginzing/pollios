if @auth.present?
  if @auth.activate_account?
      json.response_status "OK"
      json.member_detail do
      json.partial! 'response_helper/authenticate/info', member: member
      json.first_signup @auth.first_signup
      json.token member.get_token("sentai")
    end
  else
      json.member_id member.id
      json.request_code member.get_request_code
      json.response_status "WAITING"
      json.response_message "Waiting activate your account."
  end

else
  json.response_status "ERROR"
  json.response_message @response["response_message"]
end