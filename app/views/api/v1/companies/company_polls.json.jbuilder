# if @polls
#   json.response_status "OK"
#   json.company_polls @polls, partial: 'response_helper/company/list_company_polls', as: :poll
#   json.total_entries @total_entries
#   json.next_cursor @next_cursor
# else
#   json.response_status "ERROR"
# end

if @polls
  json.response_status "OK"
  json.company_polls @polls do |poll|
    if poll.series
      json.questionnaire do
        json.partial! 'response_helper/company/list_questionnaire', poll: poll
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
        json.partial! 'response_helper/company/list_polls', poll: poll
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

  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
  
else
  json.response_status "ERROR"
end