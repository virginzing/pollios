# == Schema Information
#
# Table name: mentions
#
#  id               :integer          not null, primary key
#  comment_id       :integer
#  mentioner_id     :integer
#  mentioner_name   :string(255)
#  mentionable_id   :integer
#  mentionable_name :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'test_helper'

class MentionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
