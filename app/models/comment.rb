class Comment < ActiveRecord::Base
  belongs_to :poll
  belongs_to :member

  has_many :mentions, dependent: :destroy

  has_many :member_mentionable, foreign_key: "comment_id", class_name: "Mention"
  has_many :get_member_mentionable, through: :member_mentionable, source: :mentionable

  after_commit :send_notification, on: :create

  scope :valid, -> { where(delete_status: false) }

  self.per_page = 10

  def send_notification
    unless Rails.env.test?
      CommentPollWorker.perform_async(self.member_id, self.poll_id, { comment_message: self.message })
    end
  end

  def create_mentions_list(mentioner, mentionable_list)
    mentionable_list = Member.where(id: mentionable_list)
    mentionable_list.collect{|e| mentions.create!(mentioner_id: mentioner.id, mentioner_name: mentioner.get_name, mentionable_id: e.id, mentionable_name: e.get_name) }
  end
  
end
