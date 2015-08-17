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

  json.count do
    json.point member.point
    json.reward member.cached_get_my_reward.count
  end
end
