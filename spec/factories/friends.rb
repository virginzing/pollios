FactoryGirl.define do
  factory :friend do
    follower nil
    followed nil
    active true
    following false
  end

end
