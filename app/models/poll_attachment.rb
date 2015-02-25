class PollAttachment < ActiveRecord::Base
  belongs_to :poll

  mount_uploader :image, PollAttachmentUploader
end
