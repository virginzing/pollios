if @friend.present?
  json.response_status "OK"
  json.partial! 'response_helper/member/short_info_feed', member: @friend
else
  json.response_status "ERROR"
  json.response_message "You have ever been following"
end