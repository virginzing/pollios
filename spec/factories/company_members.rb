# == Schema Information
#
# Table name: company_members
#
#  id         :integer          not null, primary key
#  company_id :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :company_member do
    company nil
    member nil
    main_group true
  end

end
