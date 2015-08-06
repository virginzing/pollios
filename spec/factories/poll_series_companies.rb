# == Schema Information
#
# Table name: poll_series_companies
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  company_id     :integer
#  post_from      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :poll_series_company do
    poll_series nil
company nil
post_from "MyString"
  end

end
