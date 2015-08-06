# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  poll_id      :integer
#  member_id    :integer
#  message      :text
#  created_at   :datetime
#  updated_at   :datetime
#  report_count :integer          default(0)
#  ban          :boolean          default(FALSE)
#  deleted_at   :datetime
#

require 'rails_helper'

RSpec.describe Comment, :type => :model do

  describe "Attribute Validations" do
    it { should validate_presence_of(:message) }
  end

  describe "Association Validations" do
    it { should belong_to(:member) }
    it { should belong_to(:poll) }
  end

end
