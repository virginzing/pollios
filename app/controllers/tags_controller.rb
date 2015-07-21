class TagsController < ApplicationController

  def index
    @tags = Tag.order("name asc")
    respond_to do |wants|
      wants.json { render json: @tags.tokens(params[:q]).as_json(), root: false }
    end
  end

  def search_autocmp_tags
    @tags = Tag.search_autocmp_tags(params["q"].rstrip)

    if @tags.present?
      @tags = @tags
    else
      @tags = []
    end
    @tags_json = ActiveModel::ArraySerializer.new(@tags, each_serializer: SearchAutocmpTagSerializer)
    respond_to do |wants|
      # wants.json { render json: @tags_json, root: false }
      wants.json { render json: @tags.map(&:name), root: false }
    end
  end

  def list_tag_all
    @tags = Tag.cached_tag_all
  end

  def search_tag
    @tags = Tag.joins(:taggings)
  end

end
