# == Schema Information
#
# Table name: group_companies
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  company_id :integer
#  created_at :datetime
#  updated_at :datetime
#  main_group :boolean          default(FALSE)
#

class GroupCompany < ActiveRecord::Base
  belongs_to :group
  belongs_to :company
end
