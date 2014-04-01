json.id poll.id
json.title poll.title
json.vote_count poll.vote_all
json.view_count poll.view_all
json.expire_date poll.expire_date.to_i
json.created_at poll.created_at.to_i
json.voted_detail @current_member.list_voted?(@history_voted, poll.id)
json.vote_max do
  json.answer poll.answer
  json.vote poll.vote_max
end
json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
json.choice_count poll.choice_count
json.series poll.series
json.tags poll.cached_tags
json.campaign poll.get_campaign
json.share_count poll.share_count
json.is_public poll.public
json.type_poll poll.type_poll
