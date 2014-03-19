if @friend.present?
  json.response_status "OK"
  json.partial! 'members/detail', member: @friend
else
  json.response_status "ERROR"
  json.response_message "You have ever been follow this celeb."
end