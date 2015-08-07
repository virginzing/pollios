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

class PollAttachment < ActiveRecord::Base
  belongs_to :poll

  mount_uploader :image, PollAttachmentUploader
end
