json.partial! 'response_helper/member/short_info', member: friend

json.count do
  
  if friend.id == member.id
    json.poll member.cached_poll_member_count
    json.vote member.cached_voted_count
    json.group member.cached_get_group_active.count
  else
    json.vote friend.cached_voted_friend_count(member)
    json.group friend.cached_groups_friend_count(member)
    json.activity friend.get_activity_count
  end

  json.activity friend.get_activity_count
  json.message 0
  json.status 0
  json.friend friend.cached_get_friend_active.count
  json.following friend.cached_get_following.count
  json.follower friend.cached_get_follower.count if friend.celebrity?
end
