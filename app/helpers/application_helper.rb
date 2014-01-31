module ApplicationHelper
  def flash_class(level)
      case level
          when :notice then "alert-box"
          when :success then "alert-box success"
          when :error then "alert-box alert"
      end
  end
end



# curl -H "Content-Type: application/json" -d '{"member_id": 4, "friend_id": 2}' -X POST http://localhost:3000/friend/add_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": }' -X POST http://localhost:3000/friend/add_celebrity.json -i

# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/block.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/unblock.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unmute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unfriend.json -i

# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 4}' -X POST http://localhost:3000/friend/accept.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 90}' -X POST http://localhost:3000/friend/deny.json -i

# curl -H "Content-Type: application/json" -d '{"member_id": 1}' -X POST http://localhost:3000/friend/all.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1}' -X POST http://localhost:3000/friend/request.json -i
# curl -H "Content-Type: application/json" -d '{"q": "nuttapon509", "member_id": 90 }' -X POST http://localhost:3000/friend/search.json -i

# curl -F "member_id=1" -F "name=Nutty" -F "friend_id=97,98,99" http://localhost:3000/group/build.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 1, "group_id": 10 }' -X POST http://localhost:3000/group/delete_group.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 30 }' -X POST http://localhost:3000/group/accept.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 17 }' -X POST http://localhost:3000/group/deny_group.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 17 }' -X POST http://localhost:3000/group/leave_group.json -i

# # curl -H "Content-Type: application/json" -d '{
# #     "group_id": 14,
# #     "member_id": 1,
# #     "friend_id": [3]
# # }' -X POST http://localhost:3000/group/add_friend_to_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "title": "คิดว่าใครเป็น Batman ที่ดีที่สุด (เฉพาะที่เป็นคนแสดง ไม่นับการ์ตูน)",
#     "expire_date": "1",
#     "choices": "Christian Bale, Christian Bale, Christian Bale, Christian Bale"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "poll_id": "36",
#     "choice_id": "57"
# }' -X POST http://localhost:3000/poll/vote.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "poll_id": "36"
# }' -X POST http://localhost:3000/poll/view.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/public.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "friend_id": "2"
# }' -X POST http://localhost:3000/member/detail_friend.json -i

# curl -H "Content-Type: application/json" -d '{"authen":"nuttapon509","password":"mefuwfhfu"}' -X POST http://localhost:3000/authen/signin_sentai.json -i
# curl -F "email=manchester@gmail.com" -F "password=mefuwfhfu" -F "username=manchester" -F "fullname=Manchester United" -F "avatar=@avatar/manu.png" -X POST http://localhost:3000/authen/signup_sentai.json -i
# curl -F "sentai_id=34" -F "fullname=Welbeck" -F "username=codeapp" -F "birthday=1990-01-15" -F "avatar=@avatar/welbak.jpg" -X POST http://localhost:3000/authen/update_sentai.json -i
