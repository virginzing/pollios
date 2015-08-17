require 'faker'

FactoryGirl.define do
  factory :comment do
    poll_id nil
    member_id nil
    message ""
  end

  factory :comment_required, class: Comment do
    poll nil
    member nil
    message Faker::Lorem.sentence
  end

end
