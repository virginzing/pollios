if @poll.present?
  json.response_status "OK"
  json.partial! 'response_helper/poll/normal', poll: @poll
  json.original_polls @poll.get_original_polls if @poll.photo_poll.present?
  
  json.choices @poll.cached_choices do |choice|
    json.choice_id choice.id
    json.answer choice.answer
    if @expired
      json.vote choice.vote
    elsif @voted["voted"] || (!@poll.creator_must_vote && (@poll.member_id  == @current_member.id))
      json.vote choice.vote
    else
      
    end
  end
else
  json.response_status "ERROR"
end