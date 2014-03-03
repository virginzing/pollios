if @friend_active || @your_request || @friend_request
  json.response_status "OK"
  json.your_request do
    json.array! @your_request.citizen do |member|
      json.id member.id
      json.type member.member_type_text
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
    end
  end
  json.friend_request do
    json.array! @friend_request.citizen do |member|
      json.id member.id
      json.type member.member_type_text
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
    end
  end
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

