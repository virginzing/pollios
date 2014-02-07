if @group_active
  json.response_status "OK"
  json.group_active @group_active, partial: 'group/detail', as: :group

else
  json.response_status "ERROR"
  json.response_message "Unable.."
end