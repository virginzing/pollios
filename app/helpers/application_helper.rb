module ApplicationHelper
  def flash_class(level)
      case level
        when :notice then "alert alert-warning"
        when :success then "alert alert-success"
        when :error then "alert alert-danger"
      end
  end

  def is_active_new_poll(c_name, a_name)
    if controller_name == c_name 
      if action_name == a_name
        'active'
      end
    end
  end

  def is_active_2nd_level(c_name, a_name)
    if controller_name == c_name
      if action_name == a_name
        'active'
      end
    end
  end

  def manage_flash(flash, title = "", message = "", color = "", icon = "")
    if flash.present?
      flash.each do |name, msg|
        if name == :warning
          title = "Warning"
          color = "#C46A69"
          icon  = "fa fa-warning"
        elsif name == :success
          title = "Success"
          color = "#739E73"
          icon  = "fa fa-check"
        end

        message = msg
      end
    end
    [title, message, color, icon]
  end

  def is_active_3rd_level(c_name, a_name)
    if controller_name == c_name
      if (action_name == 'binary') || (action_name == 'rating') || (action_name == 'freeform')
        'active'
      elsif (action_name == 'normal') || (action_name == 'same_choice')
        'active'
      else
      end
    end
  end

  def active_class(name)
    if controller_name == name
      'active'
    end
  end

  def is_active?(name)
    controller_name == name ? 'active' : nil
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

  def qr_code(size, url)
    "https://chart.googleapis.com/chart?cht=qr&chld=l&chs=#{size}x#{size}&chl=#{url}"
  end


end


# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 6 }' -X POST http://localhost:3000/friend/following.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 6 }' -X POST http://localhost:3000/friend/unfollow.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 2, "friend_id": 26 }' -X POST http://localhost:3001/friend/add_friend.json -i
#  curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/block.json -i
#  curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/add_close_friend.json -i
#  curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/unclose_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/unblock.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unmute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2 }' -X POST http://localhost:3000/friend/unfriend.json -i

# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 26, "friend_id": 2 }' -X POST http://localhost:3001/friend/accept.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 22, "friend_id": 2 }' -X POST http://localhost:3000/friend/deny.json -i

# http://localhost:3000/friend/all.json?member_id=11
# http://localhost:3000/friend/request.json?member_id=15
# http://codeapp-pollios.herokuapp.com/friends/following.json?member_id=20
# http://localhost:3000/friend/search.json?member_id=1&q=N

# curl -F "member_id=1" -F "name=Nutty" -F "friend_id=2" http://localhost:3000/group/build.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 1, "group_id": 10 }' -X POST http://localhost:3000/group/delete_group.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 17 }' -X POST http://localhost:3000/group/deny_group.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 17 }' -X POST http://localhost:3000/group/leave_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "group_id": 33,
#     "member_id": 1,
#     "friend_id": "2"
# }' -X POST http://localhost:3000/group/add_friend.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1,
#     "friend_id": "2"
# }' -X POST http://localhost:3000/group/13/invite.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 21,
#     "id": 143,
#     "qrcode_key": "46357f8468f1e92f9206071aceffa137"
# }' -X POST http://codeapp-pollios.herokuapp.com/scan_qrcode.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 2
# }' -X POST http://localhost:3000/group/13/leave.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 2
# }' -X POST http://localhost:3000/group/14/accept.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1,
#     "poll_template": [{ "choices": ["1","2"], "seaj": "5099"}, {"choices": ["3","4"]}]
# }' -X POST http://localhost:3000/templates.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1, 
#     "title": "in group by nutty",
#     "expire_within": "2",
#     "choices": "1,2",
#     "type_poll": "binary",
#     "group_id": "14"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1, 
#     "title": "Friend 8 create two #lovely #Nuttapon My name is #eiei",
#     "expire_within": "5",
#     "choices": "1,2",
#     "type_poll": "freeform"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 9, 
#     "title": "No friend create poll",
#     "expire_within": "5",
#     "choices": "1,2,3",
#     "type_poll": "freeform"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 11, 
#     "title": "MK MK",
#     "expire_within": "1",
#     "choices": "yes,no",
#     "type_poll": "binary"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 2, 
#     "title": "create in group 8 kub",
#     "expire_within": "1",
#     "choices": "yes,no",
#     "type_poll": "binary",
#     "group_id": "8"
# }' -X POST http://localhost:3000/poll/create.json -i

# PollMember.select(:poll_id ,:share_poll_of_id).where("member_id IN (?) AND share_poll_of_id != ?",[2,3], 0).group(:share_poll_of_id) | 
# PollMember.select(:poll_id).where("member_id = ? OR member_id IN (?) AND share_poll_of_id == 0",1,[2,3]).group(:poll_id).map(&:poll_id)

# PollMember.find_by_sql("SELECT pl.poll_id FROM poll_members pl LEFT JOIN poll_members pr ON pr.member_id IN (2,3) AND pl.poll_id > pr.poll_id AND (pl.share_poll_of_id = pr.poll_id OR pl.share_poll_of_id AND pl.share_poll_of_id = pr.share_poll_of_id) WHERE pr.poll_id IS NULL AND (pl.member_id = 1 OR pl.member_id IN (2,3)) ORDER BY pl.poll_id DESC LIMIT 20")

# PollMember.find_by_sql("SELECT pl.poll_id FROM poll_members pl LEFT JOIN poll_members pr ON pr.member_id IN (2,3) AND pl.poll_id > pr.poll_id")
# Poll.joins(:poll_members).includes(:poll_series, :member).where("poll_members.poll_id < ? AND (poll_members.member_id IN (?) OR public = ?)", 2000, [1,2,3], true).order("poll_members.created_at desc")
# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1,
#     "choice_id": 798
# }' -X POST http://localhost:3000/poll/288/vote.json -i


# Tag.find_by_name("codeapp").polls.
# joins(:poll_members).
# where("(polls.public = ?) OR (poll_members.member_id = ? AND poll_members.in_group = ? AND poll_members.share_poll_of_id = 0)", true, 11, false)

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1,
#     "answer": [{"id": 134, "choice_id": 312}, {"id": 133, "choice_id": 310}]
# }' -X POST http://localhost:3000/questionnaire/5/vote.json -i


# http://localhost:3000/new_public_timeline.json?member_id=3

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1,
#     "choice_id": "886"
# }' -X POST http://localhost:3000/poll/316/vote.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 7
# }' -X POST http://localhost:3000/poll/share/325.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 7
# }' -X POST http://localhost:3000/poll/unshare/39.json -i


# curl -H "Content-Type: application/json" -d '{
#     "guest_id": "1"
# }' -X POST http://localhost:3000/poll/33/view.json -i

# curl -X GET http://localhost:3000/poll/public_timeline.json?member_id=1&api_version=5
# http://localhost:3000/poll/33/choices.json?guest_id=4&voted=no 

# http://localhost:3000/poll/tags.json?member_id=4
# http://localhost:3000/poll/guest_poll.json?guest_id=1
# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "email": "imouto@gmail.com",
#     "password": "mefuwfhfu",
#     "fullname": "imouto",
#     "username": "imouto",
#     "gender": 2,
#     "device_token": "b0e16fe8 c0c342f0 3f2b6526 46fcf7b9 386c307d 2ac40035 25c1a045 74eda775"
# }' -X POST http://localhost:3000/authen/signup_sentai.json -i



# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/163/hide.json -i

# http://localhost:3000/member/profile.json?member_id=1
# Choice.find(39).update_attributes(vote: 76842)
# Poll.find(3).update(vote_all: 542388)

# Poll.find(12).choices.sum(:vote)
# Poll.find(12).update(view_all: 273122, vote_all: 236508)
# curl -H "Content-Type: application/json" -d '{"authen":"codeapp@code-app.com","password":"1234567", "device_token": "85e017fc e80ff87b 31fdbcec 2e74a6fe 7f9b8184 29257e66 3f7743ac 4f1c6f33" }' -X POST http://localhost:3000/authen/signin_sentai.json -i
# curl -F "email=manchester@gmail.com" -F "password=mefuwfhfu" -F "username=manchester" -F "fullname=Manchester United" -X POST http://localhost:3000/authen/signup_sentai.json -i
# curl -F "sentai_id=64" -F "birthday=1990-01-15" -F "province_id=27" -X POST http://localhost:3000/authen/update_sentai.json -i




# curl -H "Content-Type: application/json" -d '{
#     "udid": "0000"
# }' -X POST http://localhost:3000/guest/try_out.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1
# }' -X POST http://localhost:3000/campaigns/9/predict.json -i


# http://localhost:3000/campaigns/list_reward.json?member_id=1&api_version=5

# curl -F "member_id=1" -F "sentai_name=Nuttapon" -X POST http://localhost:3000/member/update_profile.json -i

# curl -H "Content-Type: application/json" -d '{
#     "id": "633882377",
#     "email": "gooddymail@hotmail.com",
#     "username": "katchapon.poolpipat",
#     "name": "Katchapon Poolpipat",
#     "gender": 1
# }' -X POST http://codeapp-pollios.herokuapp.com/authen/facebook.json -i

# curl "http://localhost:3000/poll/public_timeline.json?member_id=1&api_version=5" -H 'Authorization: Token token="c55d4b810641c62156c4f419127e0bc4"' -i

# curl -H "Content-Type: application/json" -d '{
#     "id": "123456",
#     "email": "testtest@gmail.com",
#     "username": "nuttapon50999",
#     "name": "nuttapon kub",
#     "gender": 1,
#     "user_photo": "http://avatar1.jpg"
# }' -X POST http://localhost:3000/authen/facebook.json -i


# Member.all.each do |p|
#   if p.gender.nil?
#     p.gender = 0
#     p.save!
#   end
# end

# 9494bda2 b735256f 2605a681 d5aed924 8ebf55e5 3c0f73df 5a085f80 7272e811
#db = Mongoid::Sessions.default

# connection = ActiveRecord::Base.connection
# ActiveRecord::Base.connection.execute(query)
# query = "SELECT r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friends r2 ON r1.followed_id = r2.followed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = 21 GROUP BY r1.follower_id, r2.follower_id"


#redis-server /usr/local/etc/redis.conf
