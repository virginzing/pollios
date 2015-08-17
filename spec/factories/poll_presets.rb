# == Schema Information
#
# Table name: poll_presets
#
#  id         :integer          not null, primary key
#  preset_id  :integer
#  name       :string(255)
#  count      :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :poll_preset do
    preset_id 1
name "MyString"
count 1
  end

end
