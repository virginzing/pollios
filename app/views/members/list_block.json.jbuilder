if @list_block
  json.response_status "OK"
  json.list_block @list_block do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end
end