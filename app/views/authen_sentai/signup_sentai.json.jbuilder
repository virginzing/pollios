if @auth.present?
  json.response_status "OK"
  json.member_detail do
    json.partial! 'login_response/member_detail', member: member
    json.token member.get_token("sentai")
  end

else
  json.response_status "ERROR"
  json.response_message @response["response_message"]
end