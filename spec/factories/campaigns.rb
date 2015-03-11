FactoryGirl.define do
  factory :campaign do
    limit 100
    begin_sample 1
    end_sample 1
    expire Time.now + 30.days
    description "Null"
    how_to_redeem "Null"
    type_campaign 1
  end

end
