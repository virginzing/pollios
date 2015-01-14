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


# after rollback must create pollios account first

# after rollback must create system setting



# PollMember.select("poll_id").where("member_id = ? OR member_id IN (?)", 1, [2, 3]).group.order("poll_id asc")

# @series = PollSeries.create!(member_id: 8, description: "แบบสำรวจความพึงพอใจการให้บริการในการจัดโครงการสัมมนาผู้รับผิดชอบด้านพลังงาน", vote_all: 0, view_all: 0, expire_date: Time.now + 2.days)

# @polls = @series.polls.create!(title: "คุณชอบตัวละครตัวไหนมากที่สุด")
# @polls.choices.create!(answer: "จิโทเกะ")




# Member.last.update_attribute(member_type: 1)


# Member.find_each(&:save)
