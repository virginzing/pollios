if @poll_series || @poll_nonseries 
  json.response_status "OK"
  
  json.poll_series @poll_series do |poll|
    json.creator poll.cached_member

    json.list_of_poll do
      json.partial! 'response/questionnaire', poll: poll
      json.poll_within Hash["in" => "Public"]
    end
  end
  
  json.poll_nonseries @poll_nonseries do |poll|
    json.creator poll.cached_member

    json.poll do
      json.partial! 'response/poll', poll: poll
      json.poll_within Hash["in" => "Public"]
    end
  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
end
