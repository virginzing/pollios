if @current_member
  json.response_status "OK"
  json.partial! 'response_helper/member/full_info', member: @current_member
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end