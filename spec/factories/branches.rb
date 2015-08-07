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

FactoryGirl.define do
  factory :branch do
    name "MyString"
address "MyText"
company nil
  end

end
