class Recurring < ActiveRecord::Base
  include RecurringsHelper
  validates :description, :period, :end_recur, presence: true

  belongs_to :member
  belongs_to :company
  
  has_many :polls

  def self.re_create_poll(recurring_list)

    recurring_list.each do |rec|
      rec_poll = rec.polls.order("id asc")
      @first_poll = rec_poll.first
      @last_poll = rec_poll.last
      
      remove_previous_poll(@last_poll)
      begin
        @new_poll = @last_poll
        @new_poll.choices
        @copy = @new_poll.amoeba_dup
        @copy.save
      end
      
      @last_poll.tags.each do |tag|
        @copy.taggings.create!(tag_id: tag.id)
      end

      add_new_poll_to_timeline(@copy)
    end   
  end

  def self.add_new_poll_to_timeline(poll)
    poll.poll_members.create!(member_id: poll.member_id, public: poll.public, series: poll.series, expire_date: poll.expire_date, share_poll_of_id: 0)
  end

  def self.remove_previous_poll(last_poll)
    last_poll_in_timeline = PollMember.where(poll_id: last_poll.id)
    last_poll_in_timeline.delete_all if last_poll_in_timeline.present?
  end

end
