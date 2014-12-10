if @find_friend
  json.response_status "OK"
  json.status @is_friend[0]
  json.partial! 'response_helper/friend/full_info', member: @current_member, friend: @find_friend
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end