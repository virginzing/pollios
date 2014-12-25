# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# i = 50
# 50.times do
#   Member.create!(sentai_id: i, sentai_name: Faker::Name.name, username: Faker::Name.first_name, email: Faker::Internet.email, friend_limit: 500)
#   i += 1
# end

# PollMember.create(poll_id: 1, member_id: 4, share_poll_of_id: 0)
# PollMember.create(poll_id: 2, member_id: 2, share_poll_of_id: 0)
# PollMember.create(poll_id: 3, member_id: 3, share_poll_of_id: 0)
# PollMember.create(poll_id: 4, member_id: 2, share_poll_of_id: 1)
# PollMember.create(poll_id: 5, member_id: 3, share_poll_of_id: 1)
# PollMember.create(poll_id: 6, member_id: 3, share_poll_of_id: 2)
# PollMember.create(poll_id: 7, member_id: 1, share_poll_of_id: 0)


# PollMember.select("poll_id").where("member_id = ? OR member_id IN (?)", 1, [2, 3]).group.order("poll_id asc")

# @series = PollSeries.create!(member_id: 8, description: "แบบสำรวจความพึงพอใจการให้บริการในการจัดโครงการสัมมนาผู้รับผิดชอบด้านพลังงาน", vote_all: 0, view_all: 0, expire_date: Time.now + 2.days)

# @polls = @series.polls.create!(title: "คุณชอบตัวละครตัวไหนมากที่สุด")
# @polls.choices.create!(answer: "จิโทเกะ")




# Member.last.update_attribute(member_type: 1)


# Member.find_each(&:save)