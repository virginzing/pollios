count = 0

json.response_status "OK"

json.list_groups @groups do |group|
  json.partial! 'response_helper/group/default', group: group
  json.member_count group.amount_member
end

json.next_cursor_group @next_cursor_group
json.total_list_groups @total_list_groups

json.list_members @members do |member|
  json.partial! 'response_helper/member/short_info_feed', member: member
  json.status @is_friend[count]
  count += 1
end

json.next_cursor_member @next_cursor_member
json.total_list_members @total_list_members
