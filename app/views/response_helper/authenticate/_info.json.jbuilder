json.partial! 'response_helper/member/short_info'

json.birthday member.get_birthday
json.gender member.check_gender
json.province member.get_province

json.count do
  json.poll member.cached_poll_member_count
  json.vote member.cached_voted_count
  json.friend member.cached_get_friend_active.count
  json.following member.cached_get_following.count
  json.message 0
  json.status 0
end