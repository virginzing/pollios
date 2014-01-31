if @detail_friend
  json.response_status "OK"
  json.status @is_friend
  json.member_id @detail_friend.id
  json.member_type @detail_friend.member_type_text
  json.sentai_name @detail_friend.sentai_name
  json.username @detail_friend.username
  json.email @detail_friend.email
  json.avatar @detail_friend.avatar.present? ? @detail_friend.avatar : "No Image"

  json.list_poll @detail_friend.polls.includes(:member, :choices).limit(3) do |poll|
    json.poll_id poll.id
    json.title poll.title
    json.vote_all poll.vote_all
    json.view_all poll.view_all
    json.expire_date poll.expire_date.to_i
    json.created_at poll.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")

    json.list_choices poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      json.vote choice.vote if @detail_friend.list_voted?(@history_voted, poll.id)["voted"] || poll.expire_date < Time.now
    end

    json.voted_detail @detail_friend.list_voted?(@history_voted, poll.id)
    json.viewed @detail_friend.list_viewed?(@history_viewed, poll.id)
  end

  json.list_friend @detail_friend.get_friend_active.limit(5) do |friend|
    json.status @is_friend
    json.member_id @detail_friend.id
    json.member_type @detail_friend.member_type_text
    json.sentai_name @detail_friend.sentai_name
    json.username @detail_friend.username
    json.email @detail_friend.email
    json.avatar @detail_friend.avatar.present? ? @detail_friend.avatar : "No Image"
  end

else
  json.response_status "ERROR"
end


