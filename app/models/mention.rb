class Mention < ActiveRecord::Base
  belongs_to :comment
  belongs_to :mentioner, class_name: "Member"
  belongs_to :mentionable, class_name: "Member"

  after_commit :send_notification, on: :create


  def send_notification
    unless Rails.env.test?
      CommentMentionWorker.perform_async(self.mentioner_id, comment.poll.id, [self.mentionable_id])
    end
  end

end
