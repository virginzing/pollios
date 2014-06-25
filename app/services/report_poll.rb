class ReportPoll
  def initialize(member, poll_id)
    @member = member
    @poll_id = poll_id
  end

  def reporting
    unless find_report
      reporting = @member.member_report_polls.create!(poll_id: @poll_id)
    end
    reporting
  end

  private

  def find_report
    @member.member_report_polls.find_by(poll_id: @poll_id)
  end
  
end