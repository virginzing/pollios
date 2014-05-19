if @auth.authenticated?
  json.response_status "OK"
  json.member_detail do
    json.partial! 'login_response/member_detail', member: member
    json.token member.get_token("facebook")
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end