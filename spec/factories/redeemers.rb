# == Schema Information
#
# Table name: redeemers
#
#  id         :integer          not null, primary key
#  company_id :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :redeemer do
    company nil
member nil
  end

end
