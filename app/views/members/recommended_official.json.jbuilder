if @recommendations_official
  json.response_status "OK"

  json.recommendations_official @recommendations_official do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end
  
end