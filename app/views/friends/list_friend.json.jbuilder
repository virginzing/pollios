if @friend_active
  json.response_status "OK"
  json.all @friend_active do |member|
    json.id member.id
    json.type member.member_type_text
    json.name member.sentai_name
    json.username member.username
    json.avatar member.get_avatar
  end
else
  json.response_status "ERROR"
end

