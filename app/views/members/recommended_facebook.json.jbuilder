if @recommendations_facebook

  json.response_status "OK"

  json.recommendations_facebook @recommendations_facebook do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end
  
end