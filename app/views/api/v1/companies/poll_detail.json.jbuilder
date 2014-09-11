if @poll.present?
  json.response_status "OK"
  json.partial! 'response_helper/poll/normal', poll: @poll
  json.choices @poll.cached_choices do |choice|
    json.choice_id choice.id
    json.answer choice.answer
    if @expired
      json.vote choice.vote
    elsif @voted["voted"] || (!@poll.creator_must_vote && (@poll.member_id  == @current_member.id))
      json.vote choice.vote
    else
    # json.vote choice.vote
    end
  end
  json.member_voted @member_voted_poll do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end

  json.member_viewed @member_viewed_poll do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end

  json.member_not_vote @member_novoted_poll do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end

  json.member_not_view @member_noviewed_poll do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end

  json.member_view_not_vote @member_view_not_vote do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end
else
  json.response_status "ERROR"
  json.response_message "ERROR"
end