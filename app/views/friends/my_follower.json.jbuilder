if @list_follower
  count = 0
  json.response_status "OK"
  json.follower @list_follower do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
    json.status @is_friend[count]
    count += 1
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end