if @list_friend.nil?
  json.response_status "OK"
else
  json.response_status "OK"
  json.data @list_friend do |friend|
    json.friend_id friend.id
    json.sentai_name friend.sentai_name
    json.username friend.username
    json.email friend.email
    json.avatar friend.avatar.present? ? friend.avatar : "No Image"
  end
end

