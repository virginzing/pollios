class CommentsController < ApplicationController

  before_action :set_comment
  before_action :authenticate_with_token!, only: [:report]

  def destroy
    @destroy = false
    respond_to do |format|
      if @comment.destroy
        poll = @comment.poll
        poll.with_lock do
          poll.comment_count -= 1
          poll.save!
        end
        @destroy = true
        format.js
      else
        format.js
      end
    end
  end


  def report
    @init_report = Report::Comment.new(@current_member, @comment, { message: params[:message], message_preset: params[:message_preset] })
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
