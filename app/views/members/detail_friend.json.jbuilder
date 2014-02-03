if @detail_friend
  json.response_status "OK"
  json.creator do
    json.status @is_friend
    json.member_id @detail_friend.id
    json.member_type @detail_friend.member_type_text
    json.sentai_name @detail_friend.sentai_name
    json.username @detail_friend.username
    json.avatar @detail_friend.avatar.present? ? @detail_friend.avatar : "No Image"
  end

  json.list_poll @detail_friend.polls.includes(:member, :choices) do |poll|
    json.poll_id poll.id
    json.title poll.title
    json.vote_count poll.vote_all
    json.view_count poll.view_all
    json.expire_date poll.expire_date.to_i
    json.created_at poll.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")

    json.list_choices poll.choices do |choice|
      json.choice_id choice.id
      json.answer choice.answer
      json.vote_count choice.vote if @detail_friend.list_voted?(@history_voted, poll.id)["voted"] || poll.expire_date < Time.now
    end

    json.voted_detail @detail_friend.list_voted?(@history_voted, poll.id)
    json.viewed @detail_friend.list_viewed?(@history_viewed, poll.id)
  end

  json.list_friend @detail_friend.get_friend_active do |friend|
    json.status @is_friend
    json.member_id friend.id
    json.member_type friend.member_type_text
    json.sentai_name friend.sentai_name
    json.username friend.username
    json.email friend.email
    json.avatar friend.avatar.present? ? friend.avatar : "No Image"
  end

else
  json.response_status "ERROR"
end


