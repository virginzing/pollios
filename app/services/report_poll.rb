class ReportPoll
  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def reporting
    unless find_report
      reporting = @member.member_report_polls.create!(poll_id: @poll.id)
      report_increment
    end
    reporting
  end

  def report_increment
    
  end

  private

  def find_report
    @member.member_report_polls.find_by(poll_id: @poll.id)
  end
  
end