# == Schema Information
#
# Table name: save_poll_laters
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  savable_id   :integer
#  savable_type :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :save_poll_later do
    member nil
  end

end
