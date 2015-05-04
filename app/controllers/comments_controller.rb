class CommentsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_comment

  before_action :set_current_member, only: [:report]

  def destroy
    @destroy = false
    respond_to do |format|
      if @comment.destroy
        @comment.poll.decrement!(:comment_count)
        @destroy = true
        format.js
      else
        format.js
      end
    end  
  end


  def report
    @init_report = ReportComment.new(@current_member, @comment, { message: params[:message], message_preset: params[:message_preset] })
    @report = @init_report.reporting

    unless @report
      render status: :unprocessable_entity
    else
      render status: :created
    end
  end


  private

  def set_comment
    @comment = Comment.cached_find(params[:id])
  end

end