if @poll_series.present?
  json.response_status "OK"

  json.partial! '/response_helper/company/list_questionnaire', poll: @poll_series.poll_first

  json.polls @poll_series.polls.includes(:choices).order("id asc") do |poll|
  json.id poll.id
  json.title poll.title
  json.vote_all poll.vote_all
    json.choices poll.choices do |choice|
        json.choice_id choice.id
        json.vote choice.vote
        json.answer choice.answer
    end
  end

  json.member_voted @member_voted_questionnaire do |member|
    json.partial! 'response_helper/member/short_info_admin_panel', member: member
  end

  json.member_viewed @member_viewed_questionnaire do |member|
    json.partial! 'response_helper/member/short_info_admin_panel', member: member
  end

  json.member_not_vote @member_novoted_questionnaire do |member|
    json.partial! 'response_helper/member/short_info_admin_panel', member: member
  end

  json.member_not_view @member_noviewed_questionnaire do |member|
    json.partial! 'response_helper/member/short_info_admin_panel', member: member
  end

  json.member_view_not_vote @member_viewed_no_vote_questionnaire do |member|
    json.partial! 'response_helper/member/short_info_admin_panel', member: member
  end

else
  json.response_status "ERROR"
end
