if @poll_series || @poll_nonseries 
  json.response_status "OK"
  
  json.poll_series @poll_series do |poll|
    json.creator poll.cached_member

    json.list_of_poll do
      json.partial! 'response/questionnaire', poll: poll
    end
  end
  
  json.poll_nonseries @poll_nonseries do |poll|
    json.creator poll.cached_member

    json.poll do
      json.partial! 'response/poll', poll: poll
      json.vote_max do
        json.answer poll.choice_answer
        json.vote poll.vote_max
      end
    end
  end

  json.next_cursor @next_cursor
end
