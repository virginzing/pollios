class BranchDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all

  def get_total_feedback
    span_badge(object.get_questionnaire_count)
  end

  def get_total_poll
    span_badge(object.get_poll_count)
  end

end
