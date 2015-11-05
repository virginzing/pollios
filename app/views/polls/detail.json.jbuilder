if @poll.present?
  json.response_status "OK"
  json.partial! 'response_helper/poll/normal', poll: @poll
  json.original_images @poll.get_original_images if @poll.photo_poll.present?
  json.choices @choices_as_json
else
  json.response_status "ERROR"
end