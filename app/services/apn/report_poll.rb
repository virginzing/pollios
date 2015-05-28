class Apn::ReportPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def get_group_ids_of_poll
    @poll.in_group_ids.split(",").map(&:to_i)
  end

  def get_member_ids_of_poll
    GroupMember.joins(:member).where("group_id IN (?) AND is_master = 't' AND active = 't' AND members.receive_notify = 't'", get_group_ids_of_poll).pluck(:member_id).uniq || []
  end

  def recipient_ids
    get_member_ids_of_poll - [@member.id]
  end

  def member_name
    @member.get_name
  end

  def custom_message
    message = "#{member_name} reported poll: \"#{@poll.title}\""
    truncate_message(message)
  end

end
