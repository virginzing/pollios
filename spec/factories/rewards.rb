# == Schema Information
#
# Table name: rewards
#
#  id            :integer          not null, primary key
#  campaign_id   :integer
#  title         :string(255)
#  detail        :text
#  photo_reward  :string(255)
#  order_reward  :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  reward_expire :datetime
#

FactoryGirl.define do
  factory :reward do
    campaign nil
    title "MyString"
    detail "MyText"
    order_reward 0
  end

end
