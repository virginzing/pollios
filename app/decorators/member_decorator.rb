class MemberDecorator < Draper::Decorator
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
      h.cookies[:image]
    else
      if object.avatar.present?
        object.avatar.url(:thumbnail)
      else
        image_default
      end
    end
  end

  private 

  def split_email
    object.email.split("@").first
  end

  def image_default
    '/smartadmin/img/avatars/male.png'
  end

end