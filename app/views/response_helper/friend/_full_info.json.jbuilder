json.partial! 'response_helper/member/short_info', member: friend

json.count do
  if friend.id == member.id
    json.poll member.cached_my_poll.count
    json.vote member.cached_my_voted.count
    json.group member.cached_get_group_active.count
    json.watched member.cached_watched.count
  else
    json.poll friend.cached_poll_friend_count(member)
    json.vote friend.cached_voted_friend_count(member)
    json.group friend.cached_groups_friend_count(member)
    json.watched friend.cached_watched_friend_count(member)
  end

  json.activity friend.get_activity_count
  json.message 0
  json.status 0
  json.friend friend.cached_get_friend_active.count
  json.following friend.cached_get_following.count
  json.follower friend.cached_get_follower.count if friend.celebrity? || friend.brand?
end