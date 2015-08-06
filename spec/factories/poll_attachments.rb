# == Schema Information
#
# Table name: poll_attachments
#
#  id          :integer          not null, primary key
#  poll_id     :integer
#  image       :string(255)
#  order_image :integer
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :poll_attachment do
    poll nil
image "MyString"
order 1
  end

end
