# == Schema Information
#
# Table name: member_report_comments
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  comment_id     :integer
#  message        :text
#  message_preset :text
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe MemberReportComment, type: :model do

end
