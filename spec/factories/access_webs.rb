# == Schema Information
#
# Table name: access_webs
#
#  id              :integer          not null, primary key
#  member_id       :integer
#  accessable_id   :integer
#  accessable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :access_web do
    member nil
    accessable nil
  end

end
