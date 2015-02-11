require 'faker'

FactoryGirl.define do
  factory :invite do
    member_id nil
    email Faker::Internet.email
  end

end
