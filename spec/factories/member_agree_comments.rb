# == Schema Information
#
# Table name: member_agree_comments
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  comment_id :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :member_agree_comment do
    member nil
comment nil
  end

end
