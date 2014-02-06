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
    json.series poll.series
    if poll.series
      json.series_poll do
        json.poll_id poll.poll_series_id
        json.vote_all poll.poll_series.vote_all
        json.view_all poll.poll_series.view_all
        json.expire_date poll.poll_series.expire_date.to_i
        json.created_at poll.poll_series.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")
        json.title poll.poll_series.description
        json.list_poll poll.find_poll_series(poll.member_id, poll.poll_series_id) do |poll|
          json.poll_id poll.id
          json.title poll.title
          json.vote_all poll.vote_all
          json.view_all poll.view_all
          json.expire_date poll.expire_date.to_i
          json.choice_count poll.choice_count
          
          json.list_choices poll.choices do |choice|
            json.choice_id choice.id
            json.answer choice.answer
            json.vote choice.vote if @current_member.list_voted?(@history_voted, poll.id)["voted"] || poll.expire_date < Time.now
          end
        end
      end
    else
      json.poll_id poll.id
      json.title poll.title
      json.vote_all poll.vote_all
      json.view_all poll.view_all
      json.expire_date poll.expire_date.to_i
      json.created_at poll.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")
      json.voted_detail @current_member.list_voted?(@history_voted, poll.id)
      json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
      json.choice_count poll.choice_count
      
      json.list_choices poll.choices do |choice|
        json.choice_id choice.id
        json.answer choice.answer
        json.vote choice.vote if @current_member.list_voted?(@history_voted, poll.id)["voted"] || poll.expire_date < Time.now
      end
    end
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