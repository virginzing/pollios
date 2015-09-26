json.partial! 'response_helper/member/short_info', member: member

json.birthday member.get_birthday
json.gender member.check_gender
json.province member.get_province
json.first_signup member.get_first_signup
json.update_personal member.update_personal
json.notification member.notification

json.subscription do
  json.is_subscribe member.subscription
  json.subscribe_last member.subscribe_last.to_i
  json.subscribe_expire member.subscribe_expire.to_i
  json.recent_subscription member.get_recent_history_subscription
end

json.count do
  json.friend Member::MemberList.new(member).active.size
  json.friend_limit Member::FRIEND_LIMIT
  json.point member.point
  json.reward member.cached_get_my_reward.size
end
