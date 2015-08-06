# == Schema Information
#
# Table name: providers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  pid        :string(255)
#  token      :string(255)
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Provider < ActiveRecord::Base
  belongs_to :member
end
