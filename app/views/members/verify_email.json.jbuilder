if @verify_email
  json.response_status "OK"
  json.response_message "Found"
  json.partial! 'response_helper/member/short_info', member: @member
else
  json.response_status "ERROR"
  json.response_message "Not found"
end