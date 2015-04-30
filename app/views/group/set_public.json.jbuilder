if @group.valid?
  json.response_status "OK"
  json.group do
    json.partial! 'response_helper/group/full_info', group: @group
  end
else
  json.response_status "ERROR"
  json.response_message @error_message
end