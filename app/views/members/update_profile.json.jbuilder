unless @error_message.present?
  json.response_status "OK"
  json.partial! 'response_helper/member/full_info', member: @member
else
  json.response_status "ERROR"
  json.response_message @error_message
end