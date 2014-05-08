if @templates.nil?
  json.response_status "OK"
  json.poll_template []
elsif @templates.present?
  json.response_status "OK"
  json.poll_template @templates.poll_template
else
  json.response_status "ERROR"
end