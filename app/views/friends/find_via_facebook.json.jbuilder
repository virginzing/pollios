count_friend = 0

json.response_status "OK"

json.friend @list_friend do |member|
  json.partial! 'response_helper/member/short_info_feed', member: member
  json.status @list_friend_is_friend[count_friend]
  count_friend += 1
end