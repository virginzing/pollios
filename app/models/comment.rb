class Comment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :poll
  belongs_to :member

  has_many :mentions, dependent: :destroy

  has_many :member_mentionable, foreign_key: "comment_id", class_name: "Mention"
  has_many :get_member_mentionable, through: :member_mentionable, source: :mentionable

  has_many :member_report_comments, dependent: :destroy

  validates_presence_of :message

  after_commit :send_notification, on: :create
  after_commit :flush_cache

  self.per_page = 10

  default_scope { with_deleted }

  scope :without_deleted, -> { where(deleted_at: nil) }

  def send_notification
    unless Rails.env.test?
      CommentPollWorker.perform_async(self.member_id, self.poll_id, { comment_message: self.message })
    end
  end

  def create_mentions_list(mentioner, list_mentioned)
    list_member = Member.where(id: list_mentioned)
    list_member.collect{|e| mentions.create!(mentioner_id: mentioner.id, mentioner_name: mentioner.get_name, mentionable_id: e.id, mentionable_name: e.get_name) }
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @comment = find_by(id: id)
      raise ExceptionHandler::NotFound, ExceptionHandler::Message::Comment::NOT_FOUND unless @comment.present?
      @comment
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end
  
end
