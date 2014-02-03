json.poll_id poll.id
json.title poll.title
json.vote_all poll.vote_all
json.view_all poll.view_all
json.expire_date poll.expire_date.to_i
json.created_at poll.created_at.strftime("%B #{poll.created_at.day.ordinalize}, %Y")