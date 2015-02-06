if @group_active || @group_inactive
  json.response_status "OK"
  json.my_group @group_active do |group|
    json.partial! 'response_helper/group/full_info', group: group
    json.as_admin group.member_admin
  end
  json.group_request @group_inactive, partial: 'response_helper/group/request', as: :group
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end