class TagsController < ApplicationController
  def index
    @tags = Tag.order("name asc")
    respond_to do |wants|
      wants.json { render json: @tags.tokens(params[:q]) }
    end
  end
  
end
