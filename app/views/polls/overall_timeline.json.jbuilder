if @poll_series || @poll_nonseries 
  count_series = 0
  count_nonseries = 0 
  json.response_status "OK"
  
  json.poll_series @poll_series do |poll|
    json.creator poll.cached_member

    json.list_of_poll do
      json.partial! 'response/questionnaire', poll: poll
      json.my_shared check_my_shared(share_poll_ids, poll.id)
      json.other_shared @series_shared[count_series]
      count_series += 1
    end

  end
  
  json.poll_nonseries @poll_nonseries do |poll|
    json.creator poll.cached_member

    json.poll do
      json.partial! 'response/poll', poll: poll
      json.poll_within poll.get_within(@group_by_name)
    end
    
    json.my_shared check_my_shared(share_poll_ids, poll.id)
    json.other_shared @nonseries_shared[count_nonseries]
    count_nonseries += 1
  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
end
