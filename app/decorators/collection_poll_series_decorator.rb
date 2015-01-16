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

  def get_feedback_status
    if object.feedback_status
      content_tag(:label, "Active", class: 'label label-success')
    else
      content_tag(:label, "Disable", class: 'label label-default')
    end
  end
end
