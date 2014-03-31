if @poll.present?
  json.response_status "OK"

  if @poll.series
    json.creator @poll.cached_member
    json.list_of_poll do
      json.id @poll.poll_series_id
      json.vote_count @poll.poll_series.vote_all
      json.view_count @poll.poll_series.view_all
      json.expire_date @poll.poll_series.expire_date.to_i
      json.created_at @poll.poll_series.created_at.to_i
      json.title @poll.poll_series.description
      json.series @poll.series
      json.tags @poll.poll_series.cached_tags
      json.share_count @poll.share_count
      json.is_public true
      json.voted_detail @current_member.list_voted_questionnaire?(@history_voted, @poll.poll_series_id)

      json.poll @poll.find_poll_series(@poll.member_id, @poll.poll_series_id) do |poll|
        json.id poll.id
        json.title poll.title
        json.vote_count poll.vote_all
        json.view_count poll.view_all
        json.choice_count poll.choice_count
        json.voted_detail @current_member.list_voted?(@history_voted, poll.id)
        json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
      end
    end

  else
    json.creator @poll.cached_member
    json.poll do
      json.id @poll.id
      json.title @poll.title
      json.vote_count @poll.vote_all
      json.view_count @poll.view_all
      json.expire_date @poll.expire_date.to_i
      json.created_at @poll.created_at.to_i
      json.voted_detail @current_member.list_voted?(@history_voted, @poll.id)
      json.viewed @current_member.list_viewed?(@history_viewed, @poll.id)
      json.choice_count @poll.choice_count
      json.series @poll.series
      json.tags @poll.cached_tags
      json.campaign @poll.get_campaign
      json.share_count @poll.share_count
      json.is_public @poll.public
    end
  end

else
  json.response_status "ERROR"
  json.response_message "Poll may be not exist or qrocde key expired."
end