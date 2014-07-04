if @list_block
  json.response_status "OK"
  json.list_block @list_block do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end
end