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

FactoryGirl.define do
  factory :special_qrcode do
    code "MyString"
info ""
  end

end
