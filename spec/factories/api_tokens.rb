# == Schema Information
#
# Table name: api_tokens
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  token      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  app_id     :string(255)
#

FactoryGirl.define do
  factory :api_token do

  end

  factory :api_token_required, class: ApiToken do
    member nil
    token { Faker::Internet.password }
    app_id "com.pollios.polliosapp"
  end


end
