if @list_friend.nil?
  json.response_status "OK"
else
  json.response_status "OK"
  json.data @list_friend do |lf|
    json.member_id lf.id
    json.name lf.sentai_name
    json.username lf.username
    json.email lf.email
    json.avatar lf.avatar.present? ? lf.avatar : "No Image"
  end
end

