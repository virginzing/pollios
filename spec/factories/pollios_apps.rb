# == Schema Information
#
# Table name: pollios_apps
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  app_id     :string(255)
#  expired_at :date
#  platform   :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :pollios_app do
    name "MyString"
    app_id "MyString"
    expired_at "2015-07-17"
    platform 1
  end

end
