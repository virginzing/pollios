# == Schema Information
#
# Table name: special_qrcodes
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  info       :hstore
#  created_at :datetime
#  updated_at :datetime
#

class SpecialQrcode < ActiveRecord::Base
  store_accessor :info, :member_id
  store_accessor :info, :type

  validates :code, presence: true, :uniqueness => { :case_sensitive => false }
  validates :member_id, presence: true
  validates :type, presence: true
end
