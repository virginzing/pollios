include FoundationRailsHelper::FlashHelper
module ApplicationHelper
  def flash_class(level)
      case level
          when :notice then "alert-box"
          when :success then "alert-box success"
          when :error then "alert-box alert"
      end
  end

  def active_class(name)
    if controller_name == name
      'active'
    end
  end
  
end

# curl -H "Content-Type: application/json" -d '{"member_id": 3, "friend_id": 4}' -X POST http://localhost:3000/friend/add_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": }' -X POST http://localhost:3000/friend/add_celebrity.json -i

# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/block.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/unblock.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unmute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unfriend.json -i

# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 5, "friend_id": 4}' -X POST http://codeapp-pollios.herokuapp.com/friend/accept.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 90}' -X POST http://localhost:3000/friend/deny.json -i

# http://localhost:3000/friend/all.json?member_id=1
# curl -H "Content-Type: application/json" -d '{"member_id": 1}' -X POST http://localhost:3000/friend/request.json -i
# curl -H "Content-Type: application/json" -d '{"q": "nuttapon509", "member_id": 90 }' -X POST http://localhost:3000/friend/search.json -i

# curl -F "member_id=1" -F "name=Nutty" -F "friend_id=97,98,99" http://localhost:3000/group/build.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 1, "group_id": 10 }' -X POST http://localhost:3000/group/delete_group.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 33 }' -X POST http://localhost:3000/group/accept.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 17 }' -X POST http://localhost:3000/group/deny_group.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 17 }' -X POST http://localhost:3000/group/leave_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "group_id": 33,
#     "member_id": 1,
#     "friend_id": "2"
# }' -X POST http://localhost:3000/group/add_friend.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1, 
#     "title": "คุณชอบตัวเลขตัวไหนมากที่สุด",
#     "expire_date": "1",
#     "choices": "0,1,2"
# }' -X POST http://localhost:3000/poll/create.json -i

# PollMember.select(:poll_id ,:share_poll_of_id).where("member_id IN (?) AND share_poll_of_id != ?",[2,3], 0).group(:share_poll_of_id) | 
# PollMember.select(:poll_id).where("member_id = ? OR member_id IN (?) AND share_poll_of_id == 0",1,[2,3]).group(:poll_id).map(&:poll_id)

# PollMember.find_by_sql("SELECT p1.poll_id FROM poll_members p1 LEFT JOIN poll_members p2 ON p2.member_id IN (2,) AND p1.poll_id > p2.poll_id AND (p1.share_poll_of_id = p2.poll_id OR p1.share_poll_of_id AND p1.share_poll_of_id = p2.share_poll_of_id) WHERE p2.poll_id IS NULL AND (p1.member_id = 1 OR p1.member_id IN (2,3)) ORDER BY p1.poll_id DESC")
# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "poll_id": "3",
#     "choice_id": "7"
# }' -X POST http://localhost:3000/poll/vote.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "choice_id": "153",
#     "series": true
# }' -X POST http://localhost:3000/poll/64/vote.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "series": true
# }' -X POST http://localhost:3000/poll/65/view.json -i

# curl -X GET http://localhost:3000/poll/public_timeline.json?member_id=4&api_version=2

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/group.json -i

# http://localhost:3000/member/detail_friend.json?member_id=4&friend_id=1
# Choice.find(39).update_attributes(vote: 76842)
# Poll.find(3).update(vote_all: 542388)
# Poll.find(12).choices.sum(:vote)
# Poll.find(12).update(view_all: 273122, vote_all: 236508)
# curl -H "Content-Type: application/json" -d '{"authen":"nuttapon509","password":"mefuwfhfu"}' -X POST http://localhost:3000/authen/signin_sentai.json -i
# curl -F "email=manchester@gmail.com" -F "password=mefuwfhfu" -F "username=manchester" -F "fullname=Manchester United" -F "avatar=@avatar/manu.png" -X POST http://localhost:3000/authen/signup_sentai.json -i
# curl -F "sentai_id=33" -F "username=nisekoi" -X POST http://localhost:3000/authen/update_sentai.json -i
