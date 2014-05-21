if @find_friend
  json.response_status "OK"
  json.partial! 'response_helper/member/full_info', member: @find_friend
  json.entity_info Member.cached_friend_entity(@current_member, @find_friend)
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end