if @groups
  json.response_status "OK"
  json.groups @groups, partial: 'response_helper/group/full_info', as: :group
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end