json.partial! 'response_helper/member/short_info'

json.birthday member.get_birthday
json.gender member.check_gender
json.province member.get_province
json.first_signup member.first_signup
json.setting_default member.setting

json.subscription do
  json.is_subscribe member.subscription
  json.subscribe_last member.subscribe_last.to_i
  json.subscribe_expire member.subscribe_expire.to_i
end

if member.company?
  json.list_group member.company.groups do |group|
    json.partial! 'response_helper/group/full_info', group: group
  end
end

json.count do
  json.point member.point
  json.poll member.cached_my_poll.count
  json.vote member.cached_my_voted.count
  json.group member.cached_get_group_active.count
  json.activity member.get_activity_count
  json.message 0
  json.status 0
  json.friend member.cached_get_friend_active.count
  json.following member.cached_get_following.count
  json.follower member.cached_get_follower.count if member.celebrity?
end
