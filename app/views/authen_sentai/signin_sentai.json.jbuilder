if @response["response_status"] == "OK"
  puts "#{@auth.activate_account?}"
  if @auth.activate_account?
    if @auth.check_valid_member?
      json.response_status "OK"
      json.member_detail do
        json.partial! 'response_helper/authenticate/info', member: member
        json.token member.get_token("sentai")
        json.first_signup member.first_signup
      end
    else
      json.response_status "ERROR"
      json.response_message @auth.error_message
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
  json.response_message "Invalid email or password."
end