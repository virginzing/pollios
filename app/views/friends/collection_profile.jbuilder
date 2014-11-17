count_friend = 0
count_following = 0
count_follower = 0

json.response_status "OK"

json.friend @list_friend do |member|
  json.partial! 'response_helper/member/short_info_feed', member: member
  json.status @list_friend_is_friend[count_friend]
  count_friend += 1
end

json.following @list_following do |member|
  json.partial! 'response_helper/member/short_info_feed', member: member
  json.status @list_following_is_friend[count_following]
  count_following += 1
end

json.follower @list_follower do |member|
  json.partial! 'response_helper/member/short_info_feed', member: member
  json.status @list_follower_is_friend[count_follower]
  count_follower += 1
end

json.list_block @list_block do |member|
  json.partial! 'response_helper/member/short_info_feed', member: member
end
