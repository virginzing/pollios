# == Schema Information
#
# Table name: un_see_polls
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  unseeable_id   :integer
#  unseeable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :not_interested_poll do
    member nil
  end

end
