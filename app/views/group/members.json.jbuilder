json.response_status "OK"

# json.active @member_active, partial: 'response_helper/group/member_group', as: :member
# json.pending @member_pending, partial: 'response_helper/group/member_group', as: :member

count_member_acitve = 0
count_member_pending = 0
count_member_request = 0

json.active @member_active do |member|
  json.member_id member.id
  json.name member.get_name
  json.email member.email
  json.type member.member_type_text
  json.description member.get_description
  json.key_color member.get_key_color
  json.avatar member.get_avatar
  json.admin member.admin
  json.status @check_status_friend_of_member_active[count_member_acitve]
  count_member_acitve += 1
end

json.pending @member_pending do |member|
  json.member_id member.id
  json.name member.get_name
  json.email member.email
  json.type member.member_type_text
  json.description member.get_description
  json.key_color member.get_key_color
  json.avatar member.get_avatar
  json.admin member.admin
  json.status @check_status_friend_of_member_pending[count_member_pending]
  count_member_pending += 1
end

json.request @member_request do |member|
  json.member_id member.id
  json.name member.get_name
  json.email member.email
  json.type member.member_type_text
  json.description member.get_description
  json.key_color member.get_key_color
  json.avatar member.get_avatar
  json.status @check_status_friend_of_member_request[count_member_request]
  count_member_request += 1
end
