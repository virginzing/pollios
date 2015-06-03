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

  def show_cover_group_in_company
    if object.cover_preset == "0"
      image_tag( object.cover.url(:cover), data: { toggle: "tooltip", placement: "top", :'original-title' => object.name }, alt: "user", class: 'img img-responsive center-block' )    
    else
      image_tag( Group::CoverPresetSelector.new(object).show_cover_preset, class: 'img img-responsive center-block', size: '320x130')
    end
  end

  def show_cover_group_in_add_surveyor
    if object.cover_preset == "0"
      image_tag( object.cover.url(:cover), data: { toggle: "tooltip", placement: "top", :'original-title' => object.name }, alt: "user", class: 'img', size: '160x65' )    
    else
      image_tag( Group::CoverPresetSelector.new(object).show_cover_preset, class: 'img', size: '160x65')
    end
  end

  def show_group_type
    if object.company?
      content_tag(:span, "Exclusive", class: ["label label-danger"])
    else
      content_tag(:span, "Public", class: ["label label-info"])
    end
  end


end
