class MemberDecorator < Draper::Decorator
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

  def show_name
    if object.fullname.present?
      truncate_full_name(object.fullname)
    else
      truncate_full_name(split_email)
    end
  end

  def truncate_full_name(string)
    h.truncate(string, length: 12)
  end

  def show_image
    if h.cookies[:login] == 'facebook'
      cookie_image = h.cookies[:image]
      if cookie_image.nil?
        image_default
      else
        cookie_image
      end
    else
      if object.avatar.present?
        object.avatar.url(:thumbnail)
      else
        image_default
      end
    end
  end

  def header_fullanme
    content_tag(:h1, object.fullname)
  end

  def show_member_description
    content_tag(:p, object.description)
  end

  def last_activity
    content_tag(:span, nil , 'data-livestamp' => object.updated_at.to_i)
  end

  private 

  def split_email
    object.email.split("@").first
  end

  def image_default
    '/smartadmin/img/avatars/male.png'
  end

end