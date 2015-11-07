# == Schema Information
#
# Table name: branches
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  address    :text
#  company_id :integer
#  created_at :datetime
#  updated_at :datetime
#  slug       :string(255)
#  note       :text
#

require 'faker'

FactoryGirl.define do

  factory :branch do

  end

  factory :branch_required, class: Branch do
    company nil
    name Faker::Name.name
    address Faker::Address.city
  end

end
