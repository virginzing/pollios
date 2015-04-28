if @comment
  json.response_status "OK"
  json.comment CommentSerializer.new(@comment).as_json
else
  json.response_status "ERROR"
  json.response_message @error_message
end