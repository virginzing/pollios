if @list_polls
  count = 0
  json.response_status "OK"
  
  json.timeline_polls @list_polls do |poll|

    if poll.series
      json.list_of_poll do
        json.timeline_id poll.id
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
    else
      json.poll do
        json.timeline_id poll.id
        json.partial! 'response_helper/poll/normal', poll: poll
        json.my_shared poll.check_my_shared(share_poll_ids, poll.id)
        
        json.other_shared do
        if poll.share_poll == 0
          json.shared false
        else
          json.shared true
          json.shared_by poll.get_member_shared_this_poll(poll.group_of_id)
          json.shared_at poll.get_group_shared(poll.group_of_id)
        end
      end

      end
    end

    count += 1
  end

  json.next_cursor @next_cursor

end