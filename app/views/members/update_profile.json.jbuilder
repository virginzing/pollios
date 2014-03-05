unless @error_message.present?
  json.response_status "OK"
  json.partial! 'members/detail', member: @current_member
else
  json.response_status "ERROR"
  json.response_message @error_message
end