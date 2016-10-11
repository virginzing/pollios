# == Schema Information
#
# Table name: pending_votes
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  poll_id      :integer
#  choice_id    :integer
#  pending_type :string(255)
#  pending_ids  :integer          is an Array
#  created_at   :datetime
#  updated_at   :datetime
#  anonymous    :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe PendingVote, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
