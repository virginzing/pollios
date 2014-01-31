if @poll
  json.response_status "OK"
  json.public_poll @poll do |poll|
    json.creator do
      json.member_id poll.member_id
      json.member_type poll.member.member_type_text
      json.sentai_name poll.member.sentai_name
      json.username poll.member.username
      json.avatar poll.member.avatar.present? ? poll.member.avatar : "No Image"
    end

    json.poll_id poll.id
    json.title poll.title
    json.vote_all poll.vote_all
    json.view_all poll.view_all
    json.expire_date poll.expire_date.to_i
    json.created_at poll.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")
    json.voted_detail @current_member.list_voted?(@history_voted, poll.id)
    json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
    
    json.list_choices poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      json.vote choice.vote if @current_member.list_voted?(@history_voted, poll.id)["voted"] || poll.expire_date < Time.now
    end

  end
end