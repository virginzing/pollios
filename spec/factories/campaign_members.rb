# == Schema Information
#
# Table name: campaign_members
#
#  id             :integer          not null, primary key
#  campaign_id    :integer
#  member_id      :integer
#  serial_code    :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  redeem         :boolean          default(FALSE)
#  redeem_at      :datetime
#  poll_id        :integer
#  poll_series_id :integer
#  redeemer_id    :integer
#  ref_no         :string(255)
#  gift           :boolean          default(FALSE)
#  reward_status  :integer
#  deleted_at     :datetime
#  gift_log_id    :integer
#  reward_id      :integer
#

FactoryGirl.define do
  factory :campaign_member do
  
  end

end
