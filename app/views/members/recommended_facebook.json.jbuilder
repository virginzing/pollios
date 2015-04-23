if @recommendations_facebook
  facebook_count = 0
  json.response_status "OK"

  json.recommendations_facebook @recommendations_facebook do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
    json.status @list_facebook_is_friend[facebook_count]
    facebook_count += 1
  end
  
end