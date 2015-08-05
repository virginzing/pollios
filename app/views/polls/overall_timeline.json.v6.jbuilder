if @list_polls
  count = 0

  json.response_status "OK"

  json.timeline_polls @list_polls do |poll|

    if poll.series
      json.list_of_poll do
        json.timeline_id @order_ids[count]
        json.partial! 'response_helper/poll/questionnaire', poll: poll
        json.polls poll.poll_series.polls.includes(:choices).order("id asc") do |poll|
        json.id poll.id
        json.title poll.title
        json.type_poll poll.type_poll
          json.choices poll.choices do |choice|
            json.choice_id choice.id
            json.answer choice.answer
          end
        end
      end
    else
      json.poll do
        json.timeline_id @order_ids[count]
        json.partial! 'response_helper/poll/normal', poll: poll, order: @order_ids[count]
      end
    end

    count += 1
  end


  json.total_entries @total_entries
  json.next_cursor @next_cursor

end
