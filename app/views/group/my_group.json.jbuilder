if @group_active || @group_inactive
  json.response_status "OK"
  json.my_group @group_active, partial: 'group/detail', as: :group
  json.group_request @group_inactive, partial: 'group/request', as: :group
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end