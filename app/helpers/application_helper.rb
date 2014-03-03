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

  def tag_clound(tags, classes)
    max = tags.sort_by(&:count).last
    tags.each do |tag|
      index = tag.count.to_f / max.count * (classes.size - 1)
      yield(tag, classes[index.round])
    end
    
  end

  def link_to_add_fields(name, f, association, class_name)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    class_name = class_name + " add_fields"
    link_to(name, '#', class: class_name, data: {id: id, fields: fields.gsub("\n", "")})
  end

end

# curl -H "Content-Type: application/json" -d '{"member_id": 10, "friend_id": 1}' -X POST http://codeapp-pollios.herokuapp.com/friend/add_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": }' -X POST http://localhost:3000/friend/add_celebrity.json -i

# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/block.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/unblock.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unmute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unfriend.json -i

# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 10}' -X POST http://codeapp-pollios.herokuapp.com/friend/accept.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 90}' -X POST http://localhost:3000/friend/deny.json -i

# http://localhost:3000/friend/all.json?member_id=1
# curl -H "Content-Type: application/json" -d '{"member_id": 1}' -X POST http://localhost:3000/friend/request.json -i
# curl -H "Content-Type: application/json" -d '{"q": "nuttapon509", "member_id": 90 }' -X POST http://localhost:3000/friend/search.json -i

# curl -F "member_id=3" -F "name=Nutty" -F "friend_id=4,14" http://localhost:3000/group/build.json -i
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
#     "member_id": 3, 
#     "title": "คุณชอบตัวเลขตัวไหนมากที่สุด",
#     "expire_date": "5",
#     "choices": "0,1,2"
# }' -X POST http://codeapp-pollios.herokuapp.com/poll/create.json -i

# PollMember.select(:poll_id ,:share_poll_of_id).where("member_id IN (?) AND share_poll_of_id != ?",[2,3], 0).group(:share_poll_of_id) | 
# PollMember.select(:poll_id).where("member_id = ? OR member_id IN (?) AND share_poll_of_id == 0",1,[2,3]).group(:poll_id).map(&:poll_id)

# PollMember.find_by_sql("SELECT pl.poll_id FROM poll_members pl LEFT JOIN poll_members pr ON pr.member_id IN (2,3) AND pl.poll_id > pr.poll_id AND (pl.share_poll_of_id = pr.poll_id OR pl.share_poll_of_id AND pl.share_poll_of_id = pr.share_poll_of_id) WHERE pr.poll_id IS NULL AND (pl.member_id = 1 OR pl.member_id IN (2,3)) ORDER BY pl.poll_id DESC LIMIT 20")

# PollMember.find_by_sql("SELECT pl.poll_id FROM poll_members pl LEFT JOIN poll_members pr ON pr.member_id IN (2,3) AND pl.poll_id > pr.poll_id")
# Poll.joins(:poll_members).includes(:poll_series, :member).where("poll_members.poll_id < ? AND (poll_members.member_id IN (?) OR public = ?)", 2000, [1,2,3], true).order("poll_members.created_at desc")
# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1",
#     "poll_id": "3",
#     "choice_id": "7"
# }' -X POST http://localhost:3000/poll/vote.json -i

# http://localhost:3000/new_public_timeline.json?member_id=3

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "4",
#     "choice_id": "153"
# }' -X POST http://localhost:3000/poll/60/vote.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 3
# }' -X POST http://localhost:3000/poll/share/39.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 3
# }' -X POST http://localhost:3000/poll/unshare/39.json -i


# curl -H "Content-Type: application/json" -d '{
#     "guest_id": "1"
# }' -X POST http://localhost:3000/poll/33/view.json -i

# # curl -X GET http://localhost:3000/poll/public_timeline.json?member_id=4&api_version=2
# http://localhost:3000/poll/33/choices.json?guest_id=4&voted=no 

# http://localhost:3000/poll/tags.json?member_id=4
# http://localhost:3000/poll/guest_poll.json?guest_id=1
# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "email": "manchester@gmail.com",
#     "password": "mefuwfhfu",
#     "username": "manchester",
#     "fullname": "Manchester United",
#     "device_token": "acf9561f 1a50d7d2 37d1266e eefdd714 330a42ee dfd4525d df57268f b045fd59"
# }' -X POST http://localhost:3000/authen/signup_sentai.json -i

# http://localhost:3000/member/detail_friend.json?member_id=4&friend_id=1
# Choice.find(39).update_attributes(vote: 76842)
# Poll.find(3).update(vote_all: 542388)

# Poll.find(12).choices.sum(:vote)
# Poll.find(12).update(view_all: 273122, vote_all: 236508)
# curl -H "Content-Type: application/json" -d '{"authen":"trueincube@gmail.com","password":"1234567" }' -X POST http://codeapp-pollios.herokuapp.com/authen/signin_sentai.json -i
# curl -F "email=manchester@gmail.com" -F "password=mefuwfhfu" -F "username=manchester" -F "fullname=Manchester United" -X POST http://localhost:3000/authen/signup_sentai.json -i
# curl -F "sentai_id=1" -F "birthday=1990-01-15" -F "province_id=27" -X POST http://localhost:3000/authen/update_sentai.json -i




# curl -H "Content-Type: application/json" -d '{
#     "udid": "0000"
# }' -X POST http://localhost:3000/guest/try_out.json -i


# curl -H "Content-Type: application/json" -d '{
#     "id": "633882377",
#     "email": "funnysmart_online@hotmail.com",
#     "username": "NuttaponAchachotipong",
#     "name": "Nutty Nuttapon Achachotipong",
#     "gender": 0,
#     "user_photo": "http://sphotos-e.ak.fbcdn.net/hphotos-ak-prn2/t31/1398785_10152013477927378_1373506367_o.jpg"
# }' -X POST http://localhost:3000/authen/facebook.json -i



# Member.all.each do |p|
#   if p.gender.nil?
#     p.gender = 0
#     p.save!
#   end
# end

