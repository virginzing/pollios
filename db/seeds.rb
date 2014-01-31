# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

i = 50
50.times do
  Member.create!(sentai_id: i, sentai_name: Faker::Name.name, username: Faker::Name.first_name, email: Faker::Internet.email, friend_limit: 500)
  i += 1
end