FactoryGirl.define do
  factory :apn_device, class: :'Apn::Device' do
    factory :disabled_notification_apn_device, traits: [:disabled_notification]

    member
    token { Faker::Lorem.characters(64).scan(/.{8}/).join(' ') }
    api_token { Faker::Number.hexadecimal(32) }
    app_id 1
    receive_notification true

    trait :disabled_notification do
      receive_notification false
    end
  end

end
