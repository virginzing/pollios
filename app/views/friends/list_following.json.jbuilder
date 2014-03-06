if @list_following
  json.response_status "OK"
  json.following @list_following do |member|
    json.member_id member.id
    json.type member.member_type_text
    json.name member.sentai_name
    json.username member.username
    json.avatar member.get_avatar
    json.email member.email
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end