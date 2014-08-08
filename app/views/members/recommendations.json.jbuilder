if @recommendations || @mutual_friends
  json.response_status "OK"
  json.recommendations_official @recommendations do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end

  json.recommendations_mutual_friend @mutual_friends do |member|
    json.partial! 'response_helper/member/short_info', member: member
    json.mutual_friend_count @init_recommendation.get_mutual_friend_recommendations_count(member.id)
  end
end