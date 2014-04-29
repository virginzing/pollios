class TagsController < ApplicationController
  def index
    @tags = Tag.order("name asc")
    respond_to do |wants|
      wants.json { render json: @tags.tokens(params[:q]).as_json(), root: false }
    end
  end

  def search_autocmp_tags
    respond_to do |wants|
      wants.json { render json: [{ id:1, name:'#nuttapon'},{ id:2, name:'#codeapp'},{ id:3, name:'#manee'}], root: false }
    end
  end
  
end
