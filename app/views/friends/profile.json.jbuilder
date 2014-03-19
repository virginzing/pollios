if @find_friend
  json.response_status "OK"
  json.status @is_friend[0]
  json.partial! 'friends/profile_detail', member: @find_friend
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end