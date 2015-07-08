if @comment.valid?
  json.response_status "OK"

  json.comment do
    json.id @comment.id
    json.name @comment.member.get_name
    json.fullname @comment.member.get_name
    json.avatar @comment.member.get_avatar
    json.message @comment.message
    json.created_at @comment.created_at.to_i

    if @comment.mentions.size > 0
      json.list_mentioned @comment.mentions do |mention|
        json.member_id mention.mentionable_id
        json.name mention.mentionable_name
      end
    else
      json.list_mentioned ""
    end

  end
else
  json.response_status "ERROR"
  json.response_message @error_message
end
