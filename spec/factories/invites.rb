# == Schema Information
#
# Table name: invites
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  email      :string(255)
#  invitee_id :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'faker'

FactoryGirl.define do
  factory :invite do
    member_id nil
    email Faker::Internet.email
  end

end
