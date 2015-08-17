# == Schema Information
#
# Table name: feedback_recurrings
#
#  id         :integer          not null, primary key
#  company_id :integer
#  period     :time
#  status     :boolean
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :feedback_recurring do

  end

end
