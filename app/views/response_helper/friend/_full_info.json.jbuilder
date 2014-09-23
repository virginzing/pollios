json.partial! 'response_helper/member/short_info', member: friend

if friend.id == member.id
  json.birthday member.get_birthday
  json.gender member.check_gender
  json.province member.get_province
  json.first_signup member.first_signup
  json.setting_default member.setting
  json.update_personal member.update_personal
  
  json.subscription do
    json.is_subscribe member.subscription
    json.subscribe_last member.subscribe_last.to_i
    json.subscribe_expire member.subscribe_expire.to_i
  end
end

json.count do
  if friend.id == member.id
    json.point member.point
    json.poll member.cached_my_poll.count
    json.vote member.cached_my_voted.count
    json.group member.cached_get_group_active.count
    json.watched member.cached_watched.count
    json.block member.cached_block_friend.count
    json.reward member.cached_get_my_reward.count
  else
    json.poll friend.cached_poll_friend_count(member)
    json.vote friend.cached_voted_friend_count(member)
    json.group friend.cached_groups_friend_count(member)
    json.watched friend.cached_watched_friend_count(member)
    json.block friend.cached_block_friend_count(member)
  end

  json.activity friend.get_activity_count
  json.message 0
  json.status 0
  json.friend friend.cached_get_friend_active.count
  json.following friend.cached_get_following.count
  json.follower friend.cached_get_follower.count if friend.celebrity? || friend.brand?
end