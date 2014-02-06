if @poll.present?
  json.response_status "OK"
  json.information @poll.slice("view_all","vote_all","expire_date").values.map! {|value| value.to_i }
  json.scroll @poll.get_choice_scroll

else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end