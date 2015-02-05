FactoryGirl.define do
  factory :friend do
    follower nil
    followed nil
    active true
    status :nofriend
  end

end
