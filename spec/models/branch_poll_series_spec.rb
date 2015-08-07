# == Schema Information
#
# Table name: branch_poll_series
#
#  id             :integer          not null, primary key
#  branch_id      :integer
#  poll_series_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe BranchPollSeries, :type => :model do

end
