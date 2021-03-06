if @recommendations_official || @people_you_may_know || @group_recomment
  count_facebook = 0

  json.response_status "OK"

  json.recommendations_official @recommendations_official do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end

  json.recommendations_group @group_recomment do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count hash_member_count[group.id] || 0
  end

  json.recommendations_mutual_friend @people_you_may_know do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end

  if @current_member.celebrity?
    json.recommendations_follower @recommendations_follower do |member|
      json.partial! 'response_helper/member/short_info_feed', member: member
    end
  end

  json.facebook @facebook do |member|
    json.partial! 'response_helper/member/short_info_feed', member: member
  end
end