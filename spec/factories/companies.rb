# == Schema Information
#
# Table name: companies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  short_name       :string(255)      default("CA")
#  member_id        :integer
#  address          :string(255)
#  telephone_number :string(255)
#  max_invite_code  :integer          default(0)
#  internal_poll    :integer          default(0)
#  using_service    :string(255)      default([]), is an Array
#  company_admin    :boolean          default(FALSE)
#

# using_service have many services such as "Survey" (Internal Survey), "Publuc" (Public Survey) and "Feedback" (Location Feedback)

require 'faker'

FactoryGirl.define do

  factory :company do
    member nil
    name "Code App"
    short_name "CA"
    using_service ["Survey"]
  end

  factory :company_admin, class: Company do
    member nil
    name "Company Admin"
    using_service ["Survey", "Feedback"]
    company_admin true
  end

  factory :company_required, class: Company do
    member nil
    name { Faker::Name.name }
    using_service ["Survey"]
  end

  factory :company_optional, class: Company do
    member nil
    name { Faker::Company.name }
    using_service ["Survey"]
    address { Faker::Address.city }
    telephone_number { Faker::Company.duns_number }
  end

end
