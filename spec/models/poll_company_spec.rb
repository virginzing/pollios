# == Schema Information
#
# Table name: poll_companies
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  company_id :integer
#  post_from  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe PollCompany, type: :model do

end
