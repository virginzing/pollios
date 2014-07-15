if @comment
  json.response_status "OK"
  # json.comment CommentSerializer.new(@comment).as_json
  json.comment do
    json.id @comment.id
    json.fullname @comment.member.get_name
    json.avatar @comment.member.get_avatar
    json.message @comment.message
    json.created_at @comment.created_at.to_i

  end
else
  json.response_status "ERROR"
  json.response_message @error_message
end