if @special_code
  json.response_status "OK"
  json.partial! 'response_helper/member/short_info', member: @member_from_special_qrcode
  json.status @is_friend[0]
else
  json.response_status "ERROR"
  json.response_message "Not Found"
end