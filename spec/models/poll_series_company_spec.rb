# == Schema Information
#
# Table name: poll_series_companies
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  company_id     :integer
#  post_from      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe PollSeriesCompany, type: :model do

end
