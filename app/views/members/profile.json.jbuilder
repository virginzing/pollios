if @current_member
  json.response_status "OK"
  json.partial! 'members/profile_detail', member: @current_member
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end