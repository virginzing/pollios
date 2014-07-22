if @poll_series || @poll_nonseries 
  json.response_status "OK"

  json.count do
    json.in_public @init_poll.watch_public_poll
    json.in_friend_following @init_poll.watch_friend_following_poll
    json.in_group @init_poll.watch_group_poll
  end
  
  json.poll_series @poll_series do |poll|

    json.list_of_poll do
      json.partial! 'response_helper/poll/questionnaire', poll: poll
    end
  end
  
  json.poll_nonseries @poll_nonseries do |poll|

    json.poll do
      json.partial! 'response_helper/poll/normal', poll: poll
    end
  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
end
