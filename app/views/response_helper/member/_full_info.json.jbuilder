json.partial! 'response_helper/member/short_info', member: member

json.count do
  json.poll member.cached_poll_member_count
  json.vote member.cached_voted_count
  json.group member.cached_get_group_active.count
  json.activity member.get_activity_count
  json.message 0
  json.status 0
  json.friend member.cached_get_friend_active.count
  json.following member.cached_get_following.count
  json.follower member.cached_get_follower.count if member.celebrity?
end