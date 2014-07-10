if @activate
  json.response_status "OK"
  json.member_detail do
    json.partial! 'response_helper/authenticate/info', member: member
    json.token member.get_token(params[:name])
    json.first_signup member.first_signup
  end
  json.response_message @invite_code[:message]
else
  json.response_status "ERROR"
  json.response_message @invite_code[:message]
end