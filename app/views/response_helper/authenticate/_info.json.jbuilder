json.partial! 'response_helper/member/short_info'

json.birthday member.get_birthday
json.gender member.check_gender
json.province member.get_province
json.first_signup member.first_signup

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
