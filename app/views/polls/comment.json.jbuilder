if @comment
  json.response_status "OK"

  json.comment do
    json.id @comment.id
    json.fullname @comment.member.get_name
    json.avatar @comment.member.get_avatar
    json.message @comment.message
    json.created_at @comment.created_at.to_i

    json.list_mentioned @comment.mentions do |mention|
      json.member_id mention.mentionable_id
      json.name mention.mentionable_name
    end

  end
else
  json.response_status "ERROR"
  json.response_message @error_message
end
