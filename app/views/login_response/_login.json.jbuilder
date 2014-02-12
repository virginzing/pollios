if @login.present?
  json.response_status "OK"
  json.member_detail do
    json.member_id @login.id
    json.sentai_id @login.sentai_id
    json.member_name @login.sentai_name
    json.member_username @login.username
    json.email @login.email
    json.avatar @login.avatar
    json.member_type @login.member_type_text
    json.access_id @apn_device.id
    json.access_token @apn_device.api_token
    json.group_active @login.group_active
  end

else
  json.response_status "ERROR"
  json.response_message "Invalid username or password."
end