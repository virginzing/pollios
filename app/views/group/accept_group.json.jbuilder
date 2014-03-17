if @group
  json.response_status "OK"
  json.group do
    json.partial! 'group/detail', group: @group
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end