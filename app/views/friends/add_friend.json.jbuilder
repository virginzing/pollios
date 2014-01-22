if @add_friend.present?
  json.response_status "OK"
  json.data @current_member.my_normally_friends do |friend|
    json.member_id friend.id
    json.name friend.sentai_name
    json.username friend.username
    json.email friend.email
    json.avatar friend.avatar.present? ? friend.avatar : "No Image"
  end
else
  json.response_status "ERROR"
  json.response_message "Cannot add your friend."
end

