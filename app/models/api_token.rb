# == Schema Information
#
# Table name: api_tokens
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  token      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  app_id     :string(255)
#

class ApiToken < ActiveRecord::Base
  belongs_to :member
end
