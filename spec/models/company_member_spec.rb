# == Schema Information
#
# Table name: company_members
#
#  id         :integer          not null, primary key
#  company_id :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe CompanyMember, :type => :model do

end
