if @group_active || @group_inactive
  json.response_status "OK"
  json.my_group @group_active do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count hash_member_count[group.id] || 0
  end
  json.group_request @group_inactive do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count group.member_count
  end

else
  json.response_status "ERROR"
  json.response_message "Unable..."
end