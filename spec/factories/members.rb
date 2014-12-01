require 'faker'

FactoryGirl.define do
  factory :member do |f|
    f.email { Faker::Internet.email }
    
  end
end
