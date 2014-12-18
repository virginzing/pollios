FactoryGirl.define do
  factory :choice do
    answer Faker::Name.name
    vote 0
    correct false
  end

end
