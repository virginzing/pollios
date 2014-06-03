json.partial! 'response_helper/member/short_info', member: friend

json.count do
  json.poll friend.cached_poll_friend_count(member)
  json.vote friend.cached_voted_friend_count(member)
  json.message 0
  json.status 0
  json.friend friend.cached_get_friend_active.count
  json.following friend.cached_get_following.count
  json.follower friend.cached_get_follower.count if friend.celebrity?
end