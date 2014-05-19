if @friend.present?
  json.response_status "OK"
  json.status @status
  json.partial! 'response_helper/member/short_info', member: @detail_friend
else
  json.response_status "ERROR"
  json.response_message "You ever add friend already."
end

