class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_current_member
  before_action :set_comment


  private

  def set_comment
    begin
      @comment = Comment.find_by(id: params[:id])
      raise ExceptionHandler::NotFound, "Comment not found." unless @comment.present?
    end    
  end

end
