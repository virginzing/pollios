class Notification::Poll::Report
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll, :reason_message

  def initialize(member, poll, reason_message)
    @sender = member
    @poll = poll
    @reason_message = reason_message

    return unless poll_in_groups?

    recipient_list.each do |recipient|
      create(recipient, type, message, data)
    end
  end

  def type
    nil
  end

  def recipient_list
    admins_of_groups
  end

  def message
    sender.fullname + " reported \"#{poll.title}\" with reason \"#{reason_message}\""
  end

  def data
    {
      type: TYPE[:poll],
      poll_id: poll.id,
      series: poll.series,
      action: ACTION[:report],
      worker: WORKER[:report_poll]
    }
  end

  private

  def poll_in_groups?
    poll.in_group
  end

  def admins_of_groups
    group_list.map { |group| Group::MemberList.new(group, viewing_member: sender).admins }.flatten.uniq
  end

end