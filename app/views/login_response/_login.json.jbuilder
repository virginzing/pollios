if @login.present?
  json.response_status "OK"
  json.member_detail do
    json.member_id @login.id
    json.sentai_id @login.sentai_id
    json.member_name @login.sentai_name
    json.member_username @login.username
    json.email @login.email
    json.avatar @login.avatar
    json.member_token @login.token
    json.public_id @login.public_id
    json.group_active @login.group_active
  end

else
  json.response_status "ERROR"
  json.response_message "Invalid username or password."
end