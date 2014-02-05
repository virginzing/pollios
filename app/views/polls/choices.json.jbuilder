if @choices.present?
  json.response_status "OK"
  
  json.choices @choices do |choice|
    json.id choice.id
    json.answer choice.answer
    unless params[:voted] == "no"
      json.vote choice.vote if @voted || @expired
    end
  end
else
  json.response_status "ERROR"
end