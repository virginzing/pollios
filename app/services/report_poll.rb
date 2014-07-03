class ReportPoll
  def initialize(member, poll, options = {})
    @member = member
    @poll = poll
    @options = options
  end

  def reporting
    unless find_report
      reporting = @member.member_report_polls.create!(poll_id: @poll.id, message: @options[:message])
      report_increment
    end
    reporting
  end

  def report_increment
    report_power = @member.report_power
    @poll.increment!(:report_count, report_power)
  end

  private

  def find_report
    @member.member_report_polls.find_by(poll_id: @poll.id)
  end
  
end