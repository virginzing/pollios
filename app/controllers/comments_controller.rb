class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_comment

  def destroy
    @destroy = false
    respond_to do |format|
      if @comment.update(delete_status: true)
        @comment.poll.decrement!(:comment_count)
        @destroy = true
        format.js
      else
        format.js
      end
    end  
  end


  private

  def set_comment
    begin
      @comment = Comment.find_by(id: params[:id])
      raise ExceptionHandler::NotFound, "Comment not found." unless @comment.present?
    end    
  end

end
