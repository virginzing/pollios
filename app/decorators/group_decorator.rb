class GroupDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


  def show_cover_group
    if object.cover_preset == "0"
      image_tag( object.cover.url(:thumbnail_small), data: { toggle: "tooltip", placement: "top", :'original-title' => object.name }, alt: "user", class: 'img img-responsive center-block' )    
    else
      image_tag( Group::CoverPresetSelector.new(object).show_cover_preset, class: 'img img-responsive center-block', size: '120x60')
    end
  end

  def show_group_type
    if object.company?
      "Exclusive"  
    else
      "Normal"
    end
  end


end
