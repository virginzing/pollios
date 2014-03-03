if @member.present?
  json.response_status "OK"
  json.member_detail do
    json.member_id @member.id
    json.sentai_id @member.sentai_id
    json.name @member.sentai_name
    json.username @member.username
    json.email @member.email
    json.birthday @member.birthday.present? ? @member.birthday : ""
    json.gender @member.check_gender
    json.province @member.get_province
    json.avatar @member.avatar
    json.type @member.member_type_text

    json.stats @stats_all
    if @apn_device.present?
      json.access_id @apn_device.id
      json.access_token @apn_device.api_token
    end
    json.group_active @member.group_active
  end

else
  json.response_status "ERROR"
  json.response_message "Unable..."
end