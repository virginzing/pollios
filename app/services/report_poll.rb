class ReportPoll

  NUMBER_REPORT_COUNT = 10

  def initialize(member, poll, options = {})
    @member = member
    @poll = poll
    @options = options
  end

  def reporting
    unless find_report
      reporting = @member.member_report_polls.create!(poll_id: @poll.id, message: @options[:message], message_preset: @options[:message_preset])
      report_increment
      send_notification if in_group?
      clear_cached
      SavePollLater.delete_save_later(@member.id, @poll)
      FlushCached::Member.new(@member).clear_list_report_polls
    end
    reporting
  end

  def report_increment
    report_power = @member.report_power
    @poll.increment!(:report_count, report_power)

    if @poll.report_count >= NUMBER_REPORT_COUNT
      @poll.update!(status_poll: :black)
    end
  end

  def clear_cached
    @member.flush_cache_about_poll
  end

  def send_notification
    ReportPollWorker.perform_async(@member.id, @poll.id)
  end

  private

  def find_report
    @member.member_report_polls.find_by(poll_id: @poll.id)
  end

  def in_group?
    @poll.in_group
  end
  
end