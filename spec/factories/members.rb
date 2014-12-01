require 'faker'

FactoryGirl.define do
  factory :one, class: Member do
    email "nuttapon@code-app.com"
  end

  factory :two, class: Member do
    email "nutty@code-app.com"
  end
end
