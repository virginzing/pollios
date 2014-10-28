class Apn::ReportPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def get_group_ids_of_poll
    @poll.in_group_ids.split(",").collect{|e| e.to_i }
  end

  def get_member_ids_of_poll
    GroupMember.where("group_id IN (?) AND is_master = 't' AND active = 't'", get_group_ids_of_poll).map(&:member_id).uniq
  end

  def recipient_ids
    get_member_ids_of_poll
  end

  def member_name
    @member.fullname
  end

  def custom_message
    message = "#{member_name} reported poll: \"#{@poll.title}\""
    truncate_message(message)
  end

end
