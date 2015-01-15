if @special_code
  json.partial! 'response_helper/member/short_info', member: @current_member
else
  json.response_status "ERROR"
  json.response_message "Not Found"
end