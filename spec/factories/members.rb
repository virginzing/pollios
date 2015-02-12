require 'faker'

FactoryGirl.define do

  factory :member do
    fullname "Nuttapon"
    email Faker::Internet.email
  end

  factory :one, class: Member do
    email "nuttapon@code-app.com"
  end

  factory :two, class: Member do
    email "nutty@code-app.com"
  end

  factory :facebook, class: Member do
    id "123456"
    name "Nutty Nuttapon Achachotipong"
    app_id "123"
  end

  factory :sentai, class: Member do
    authen "nuttapon@code-app.com"
    password "1234567"
    app_id "123"
  end

  factory :celebrity, class: Member do
    fullname "celebrity"
    email "celebrity@gmail.com"
    member_type 1
  end

end