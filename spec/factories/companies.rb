FactoryGirl.define do
  factory :company do
    member nil
    name "Code App"
    short_name "CA"
    using_service ["Survey"]
  end

end
