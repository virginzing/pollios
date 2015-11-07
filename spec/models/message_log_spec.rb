# == Schema Information
#
# Table name: message_logs
#
#  id          :integer          not null, primary key
#  admin_id    :integer
#  message     :string(255)
#  list_member :text             default([]), is an Array
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe MessageLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
