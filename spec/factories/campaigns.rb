FactoryGirl.define do
  factory :campaign do
    limit 100
    begin_sample 1
    end_sample 1
    expire Time.now + 30.days
    description "description"
    how_to_redeem "how to redeem"
    type_campaign 1
    reward_expire Time.now + 100.days
  end

end
