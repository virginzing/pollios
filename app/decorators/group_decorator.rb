class GroupDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


  def show_cover_group
    image_tag( object.cover.url(:thumbnail_small), data: { toggle: "tooltip", placement: "top", :'original-title' => object.name }, alt: "user", class: 'img img-responsive center-block' )    
  end


end
