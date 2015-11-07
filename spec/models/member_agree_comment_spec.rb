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

require 'rails_helper'

RSpec.describe MemberAgreeComment, type: :model do

  it { should belong_to(:member) }

  it { should belong_to(:comment) }
end
