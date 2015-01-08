class ApplicationDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatingDecorator
  end

  def span_badge(amount)
    content_tag(:span, amount, class: 'badge bg-color-blueLight')
  end
  
end