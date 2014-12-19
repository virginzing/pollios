class PollDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def page_number
    42
  end

  def get_vote_count
    span_badge(object.vote_all)
  end

  def get_view_count
    span_badge(object.view_all)
  end

  def get_report_count
    span_badge(object.report_count)
  end

  def expire_status
    object.expire_date > Time.zone.now ? content_tag(:span, "yet", class: 'label label-success') : content_tag(:span, 'expired', class: 'label label-danger')
  end

  def create_since
    content_tag(:span, nil , 'data-livestamp' => object.created_at.to_i)
  end

  def header_title
    content_tag(:h1, object.title)
  end

  def created_at
    object.created_at.strftime("%d %B %Y")
  end

  def poll_in_group
    content_tag(:li) do
      poll.groups.map do |group|
        concat(content_tag(:span, link_to(group.name, company_group_detail_path(group)), class: 'group_label'))
      end
    end
  end

  def get_photo_poll
    if photo_poll.present?
      image_tag(object.photo_poll.url(:thumbnail))  
    else
      image_tag('logo.png')
    end
  end
  
  private

  def span_badge(amount)
    content_tag(:span, amount, class: 'badge bg-color-blueLight')
  end


end

