# == Schema Information
#
# Table name: request_codes
#
#  id                :integer          not null, primary key
#  member_id         :integer
#  custom_properties :text
#  created_at        :datetime
#  updated_at        :datetime
#

class RequestCode < ActiveRecord::Base
  serialize :custom_properties, Hash
  
  belongs_to :member
end
