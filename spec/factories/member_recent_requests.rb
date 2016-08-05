# == Schema Information
#
# Table name: member_recent_requests
#
#  id          :integer          not null, primary key
#  member_id   :integer
#  recent_id   :integer
#  recent_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :member_recent_request do
    member nil
recent nil
  end

end
