if @group_active || @group_inactive
  json.response_status "OK"
  json.my_group @group_active, partial: 'response_helper/group/full_info', as: :group
  json.group_request @group_inactive, partial: 'response_helper/group/request', as: :group
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end