if @poll_series || @poll_nonseries

  json.response_status "OK"
  
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
  json.next_cursor @next_cursor

end
