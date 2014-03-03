if @login.present?
  json.response_status "OK"
  json.member_detail do
    json.member_id @login.id
    json.sentai_id @login.sentai_id
    json.name @login.sentai_name
    json.username @login.username
    json.email @login.email
    json.birthday @login.birthday.present? ? @login.birthday : ""
    json.gender @login.check_gender
    json.province @login.get_province
    json.avatar @login.avatar
    json.type @login.member_type_text
    json.stats @stats_all
    if @apn_device.present?
      json.access_id @apn_device.id
      json.access_token @apn_device.api_token
    end
    json.group_active @login.group_active
  end

else
  json.response_status "ERROR"
  json.response_message "Invalid username or password."
end