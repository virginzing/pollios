class AskJoinGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, group, poll, action = "asked")
    @member = member
    @group = group
    @poll = poll
    @action = action
  end

  def group_member_ids
    @group.get_member_open_notification.collect(&:id).flatten - [@member.id]
  end

  def recipient_ids
    @group.present? ? group_member_ids : []
  end

  def member_name
    @member.fullname
  end

  def group_name
    # truncate(group.name, length: 10)
    @group.name
  end

  def custom_message
    if @action == "asked"
      message = "#{member_name} asked in #{group_name}: \"#{@poll.title}\""
    else
      message = "#{member_name} joined in #{group_name}"
    end
    truncate_message(message)
  end 

  ## for commit 
  
end
