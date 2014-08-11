if @recommendations || @mutual_friends
  json.response_status "OK"
  json.recommendations_official @recommendations do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end

  json.recommendations_mutual_friend @mutual_friends do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end
end