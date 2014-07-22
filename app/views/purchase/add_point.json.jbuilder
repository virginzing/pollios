if @add_point_count > 0
  json.response_status "OK"
  json.response_message "Add Success"
  json.member_detail do
    json.partial! 'response_helper/authenticate/info', member: member
  end
else
  json.response_status "OK"
  json.response_message "Nothing"
  json.member_detail do
    json.partial! 'response_helper/authenticate/info', member: member
  end
end
