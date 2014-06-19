if @friend
  count = 0
  json.response_status "OK"
  json.follower @friend do |member|
    json.partial! 'response_helper/member/short_info', member: member
    json.status @is_friend[count]
    count += 1
  end
else
  json.response_status "ERROR"
  json.response_message "No Found."
end