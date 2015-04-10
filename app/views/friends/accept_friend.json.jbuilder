if @accept_friend
  json.response_status "OK"
  # json.status @status
  # json.active @active
  # json.partial! 'response_helper/member/short_info_feed', member: @detail_friend
else
  json.response_status "ERROR"
  json.response_message "Something went wrong, please try again"
end