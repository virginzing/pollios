# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  poll_id      :integer
#  member_id    :integer
#  message      :text
#  created_at   :datetime
#  updated_at   :datetime
#  report_count :integer          default(0)
#  ban          :boolean          default(FALSE)
#  deleted_at   :datetime
#

class Comment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :poll
  belongs_to :member

  has_many :mentions

  has_many :member_mentionable, foreign_key: "comment_id", class_name: "Mention"
  has_many :get_member_mentionable, through: :member_mentionable, source: :mentionable

  has_many :member_report_comments

  validates_presence_of :message

  after_commit :send_notification, on: :create
  after_commit :create_notify_log, on: :create

  after_commit :flush_cache

  # after_save :increase_poll_comment_count

  self.per_page = 10

  default_scope { with_deleted }

  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :without_ban, -> { where(ban: false) }

  scope :viewing_by_member, (lambda do |viewing_member|
    incoming_block_ids = Member::MemberList.new(viewing_member).blocked_by_someone
    where('member_id NOT IN (?)', incoming_block_ids) if incoming_block_ids.count > 0
  end)

  def send_notification
    unless Rails.env.test?
      CommentPollWorker.perform_async(self.member_id, self.poll_id, { comment_message: self.message } )
    end
  end

  def create_notify_log
    Poll::CommentNotifyLog.new(self).create!
  end

  def create_mentions_list(mentioner, list_mentioned)
    list_member = Member.where(id: list_mentioned)
    list_member.collect{|e| mentions.create!(mentioner_id: mentioner.id, mentioner_name: mentioner.get_name, mentionable_id: e.id, mentionable_name: e.get_name) }
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @comment = find_by(id: id)
      raise ExceptionHandler::NotFound, ExceptionHandler::Message::Comment::NOT_FOUND unless @comment.deleted_at.nil?
      @comment
    end
  end

  # THIS SHOULD WORK. DON'T KNOW WHY. BUT MAYBE WE SHOULDN'T RELY ON CALL-BACK
  # def increase_poll_comment_count
  #   self.poll.with_lock do
  #     self.poll.comment_count += 1
  #     self.poll.save!
  #   end
  # end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end
  
end
