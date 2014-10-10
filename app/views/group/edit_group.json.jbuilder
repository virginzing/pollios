if @group.present?
  json.response_status "OK"
  json.group do
    json.partial! 'response_helper/group/full_info', group: @group
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end