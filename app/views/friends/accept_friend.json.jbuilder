if @friend.present?
  json.response_status "OK"
  json.status @status
  json.active @active
  json.partial! 'members/detail', member: @detail_friend
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end