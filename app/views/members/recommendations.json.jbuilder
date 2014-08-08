if @recommendations
  json.response_status "OK"
  json.recommendations @recommendations do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end
end