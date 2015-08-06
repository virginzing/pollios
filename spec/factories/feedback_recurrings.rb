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
    company nil
    period "2015-01-14 22:16:07"
    status false
  end

end
