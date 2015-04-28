FactoryGirl.define do
  factory :poll_group do
    share_poll_of_id 0
    poll nil
    group nil
    member nil
  end

end
