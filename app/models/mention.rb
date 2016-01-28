# == Schema Information
#
# Table name: mentions
#
#  id               :integer          not null, primary key
#  comment_id       :integer
#  mentioner_id     :integer
#  mentioner_name   :string(255)
#  mentionable_id   :integer
#  mentionable_name :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Mention < ActiveRecord::Base
  belongs_to :comment
  belongs_to :mentioner, class_name: "Member"
  belongs_to :mentionable, class_name: "Member"

  after_commit :send_notification, on: :create


  def send_notification
    unless Rails.env.test?
      CommentMentionWorker.perform_async(self.mentioner_id, self.comment_id, comment.poll.id, [self.mentionable_id])
    end
  end

end
