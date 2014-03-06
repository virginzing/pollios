if @list_follower
  count = 0
  json.response_status "OK"
  json.follower @list_follower do |member|
    json.member_id member.id
    json.type member.member_type_text
    json.name member.sentai_name
    json.username member.username
    json.avatar member.get_avatar
    json.email member.email
    json.status @is_friend[count]
    count += 1
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end