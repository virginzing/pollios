if @list_following
  count = 0
  json.response_status "OK"
  json.following @list_following do |member|
    json.partial! 'members/detail', member: member
    json.status @is_friend[count]
    count += 1
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end