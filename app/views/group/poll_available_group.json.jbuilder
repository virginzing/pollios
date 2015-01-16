if @poll_series || @poll_nonseries
  json.response_status "OK"

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

  json.poll_nonseries @poll_nonseries do |poll|
    
    json.poll do
      json.partial! 'response_helper/poll/normal', poll: poll
      json.poll_within poll.get_within(@group_by_name)
      json.my_shared poll.check_my_shared(share_poll_ids, poll.id)

      json.other_shared do
        if poll.share_poll == 0
          json.shared false
        else
          json.shared true
          # json.shared_by poll.get_member_shared_this_poll(poll.group_of_id)
          # json.shared_at poll.get_group_shared(poll.group_of_id)
        end
      end

    end

  end
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end