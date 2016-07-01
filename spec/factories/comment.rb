require 'faker'

FactoryGirl.define do
  factory :comment do
    poll
    member
    message { Faker::Lorem.sentence }
  end

  factory :comment_required, class: Comment do
    poll nil
    member nil
    message { Faker::Lorem.sentence }
  end

end
