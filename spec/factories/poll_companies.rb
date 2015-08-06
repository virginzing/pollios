# == Schema Information
#
# Table name: poll_companies
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  company_id :integer
#  post_from  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :poll_company do
    poll nil
    company nil
    post_from "MyString"
  end

end
