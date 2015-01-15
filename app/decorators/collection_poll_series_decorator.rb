class CollectionPollSeriesDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all

  def get_recurring_status
    if object.recurring_status
      content_tag(:label, "ON", class: 'label label-success')
    else
      content_tag(:label, "OFF", class: 'label label-default')
    end
  end

end
