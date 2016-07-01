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

  factory :company_member_required, class: CompanyMember do
    company nil
    member nil
  end

end
