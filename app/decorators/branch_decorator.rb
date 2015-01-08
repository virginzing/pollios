class BranchDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def get_total_feedback
    span_badge(object.get_questionnaire_count)
  end

  def get_total_poll
    span_badge(object.get_poll_count)
  end

end
