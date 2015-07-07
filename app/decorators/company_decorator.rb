class CompanyDecorator < ApplicationDecorator
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

  def using_service?(name_of_service)
    object.using_service.include?(name_of_service)
  end
end
