# == Schema Information
#
# Table name: collection_poll_series_branches
#
#  id                        :integer          not null, primary key
#  collection_poll_series_id :integer
#  branch_id                 :integer
#  poll_series_id            :integer
#  created_at                :datetime
#  updated_at                :datetime
#

require 'rails_helper'

RSpec.describe CollectionPollSeriesBranch, :type => :model do

end
