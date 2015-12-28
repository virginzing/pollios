# == Schema Information
#
# Table name: poll_members
#
#  id               :integer          not null, primary key
#  member_id        :integer
#  poll_id          :integer
#  share_poll_of_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  public           :boolean
#  series           :boolean
#  expire_date      :datetime
#  in_group         :boolean          default(FALSE)
#  poll_series_id   :integer          default(0)
#

class PollMember < ActiveRecord::Base

  belongs_to :member
  belongs_to :poll, -> { having_status_poll(:gray, :white) }

  scope :available, -> {
    member_report_poll = member_reported_polls #= Member.reported_polls.map(&:id)  ## poll ids
    # member_block_and_banned = member_blocked_and_banned #= Member.list_friend_block.map(&:id) | Admin::BanMember.cached_member_ids
    member_block_and_banned =  member_blocked_and_banned | Admin::BanMember.cached_member_ids


    query = where("polls.draft = 'f' AND polls.deleted_at IS NULL")
    query = query.where("#{table_name}.poll_id NOT IN (?)", member_report_poll) if member_report_poll.size > 0
    query = query.where("#{table_name}.member_id NOT IN (?)", member_block_and_banned) if member_block_and_banned.size > 0
    query
  }

  scope :unexpire, -> {
    where("polls.expire_status = 'f'")
  }

  scope :without_closed, -> { where("polls.close_status = 'f'") }

  def self.member_reported_polls
    Member::PollList.new(Member.current_member).reports_ids
  end

  def self.member_blocked_and_banned
    Member::MemberList.new(Member.current_member).blocks_ids
  end

end
