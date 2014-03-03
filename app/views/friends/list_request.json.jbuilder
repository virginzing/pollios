if @your_request && @friend_request
  json.response_status "OK"
  json.your_request do
    json.array! @your_request.citizen do |member|
      json.member_id member.id
      json.type member.member_type_text
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
    end
  end
  json.friend_request do
    json.array! @friend_request.citizen do |member|
      json.member_id member.id
      json.type member.member_type_text
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
    end
  end
else
  json.response_status "ERROR"
end