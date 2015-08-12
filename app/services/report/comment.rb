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
    return nil unless can_report

    unless already_reported
      reporting = @member.member_report_comments.create!(poll_id: poll.id, comment_id: @comment.id, message: @options[:message], message_preset: @options[:message_preset])
      report_increment
      FlushCached::Member.new(@member).clear_list_report_comments
    end
    reporting
  end

  private

  def report_increment
    report_power = @member.report_power
    @comment.with_lock do
      @comment.report_count += report_power
      @comment.save!
    end
  end


  def can_report
    if @comment.member_id == @member.id
      return false
    end
    return true
  end

  def already_reported
    @member.member_report_comments.find_by(comment_id: @comment.id)
  end

  
end