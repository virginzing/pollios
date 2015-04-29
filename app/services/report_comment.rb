class ReportComment

  def initialize(member, comment, options = {})
    @member = member
    @comment = comment
    @options = options
  end

  def poll
    @comment.poll
  end


  def reporting
    unless find_report
      reporting = @member.member_report_comments.create!(poll_id: poll.id, comment_id: @comment.id, message: @options[:message], message_preset: @options[:message_preset])
      report_increment
      FlushCached::Member.new(@member).clear_list_report_comments
    end
    reporting
  end

  def report_increment
    report_power = @member.report_power
    @comment.increment!(:report_count, report_power)
  end

  private

  def find_report
    @member.member_report_comments.find_by(comment_id: @comment.id)
  end

  
end