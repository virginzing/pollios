require 'faker'

FactoryGirl.define do

  factory :member do
    fullname "Nuttapon"
    email "nutkub@gmail.com"  
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
  end

  factory :sentai, class: Member do
    authen "nuttapon@code-app.com"
    password "1234567"
  end

end