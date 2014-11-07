if @recommendations || @mutual_friends
  json.response_status "OK"
  json.recommendations_official @recommendations do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end

  json.recommendations_mutual_friend @mutual_friends do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end

  if @current_member.celebrity?
    json.recommendations_follower @recommendations_follower do |member|
      json.partial! 'response_helper/member/short_info_feed', member: member
    end
  end
end