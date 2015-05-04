require 'faker'

FactoryGirl.define do
  factory :comment do
    poll_id nil
    member_id nil
    message ""
  end

end
