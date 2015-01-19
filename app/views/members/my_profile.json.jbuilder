if @current_member
  json.response_status "OK"
  json.partial! 'response_helper/member/full_info', member: @current_member
  json.waiting_info @waiting_info
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end