module RecurringsHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :status, :in => { :active => 1, :inactive => -1 }, scope: :having_status, predicates: true, default: :active

  def label_use(text)
    if text == "Yes"
      content_tag(:span, text, class: "success label")
    else
      content_tag(:span, text, class: "secondary label")
    end
  end
end
