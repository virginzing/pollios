if @friend_active
  json.response_status "OK"
  json.your_request do
    json.array! @your_request do |member|
      json.member_id member.id
      json.type member.member_type_text
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
    end
  end
  json.friend_request do
    json.array! @friend_request do |member|
      json.member_id member.id
      json.type member.member_type_text
      json.name member.sentai_name
      json.username member.username
      json.avatar member.get_avatar
    end
  end
  json.all @friend_active do |member|
    json.member_id member.id
    json.type member.member_type_text
    json.name member.sentai_name
    json.username member.username
    json.avatar member.get_avatar
  end
else
  json.response_status "ERROR"
end

