if @poll_nonseries
  json.response_status "OK"
    json.count do
      json.in_public @init_poll.vote_public_poll
      json.in_friend_following @init_poll.vote_friend_following_poll
      json.in_group @init_poll.vote_group_poll
    end

  json.poll_series @poll_series do |poll|

    json.list_of_poll do
      json.partial! 'response_helper/poll/questionnaire', poll: poll

      json.polls poll.poll_series.polls.includes(:choices).order("id asc") do |poll|
      json.id poll.id
      json.title poll.title
        json.choices poll.choices do |choice|
          json.choice_id choice.id
          json.answer choice.answer
        end
      end
    end

  end

  json.poll_nonseries @poll_nonseries, partial: 'response_helper/poll/normal', as: :poll
  json.total_entries @total_entries
  json.next_cursor @next_cursor
end