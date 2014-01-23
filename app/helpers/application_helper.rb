module ApplicationHelper
  def flash_class(level)
      case level
          when :notice then "alert-box"
          when :success then "alert-box success"
          when :error then "alert-box alert"
      end
  end

end



# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/add_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/block_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 1}' -X POST http://localhost:3000/friend/unblock_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unmute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unfriend.json -i

# curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 3, "friend_id": 1}' -X POST http://localhost:3000/friend/accept_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/deny_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1}' -X POST http://localhost:3000/friend/list_friend.json -i
# curl -H "Content-Type: application/json" -d '{"q": "bxpcsure", "member_id": 1 }' -X POST http://localhost:3000/friend/search_friend.json -i

# curl -F "photo_group=@test.jpg" -F "member_id=1" -F "name=Code App1" -F "friend_id=2,3" http://localhost:3000/group/create_group.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "group_id": 10 }' -X POST http://localhost:3000/group/delete_group.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 17 }' -X POST http://localhost:3000/group/accept_group.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 17 }' -X POST http://localhost:3000/group/deny_group.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 17 }' -X POST http://localhost:3000/group/leave_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "group_id": 14,
#     "member_id": 1,
#     "friend_id": [3]
# }' -X POST http://localhost:3000/group/add_friend_to_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "title": "ทดสอบระบบครับ",
#     "expire_date": "3",
#     "group_id": "17",
#     "choices": [
#         "สุดยอดมาก",
#         "แย่มาก",
#         "ให้ตายเถอะ"
#     ]
# }' -X POST http://localhost:3000/poll/create_poll.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "poll_id": "6",
#     "choice_id": "6"
# }' -X POST http://localhost:3000/poll/vote_poll.json -i
