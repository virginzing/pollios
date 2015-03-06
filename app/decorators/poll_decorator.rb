class PollDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


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
    object.expire_status == false ? content_tag(:span, "yet", class: 'label label-success') : content_tag(:span, 'expired', class: 'label label-danger')
  end

  def create_since
    content_tag(:span, nil , 'data-livestamp' => object.created_at.to_i)
  end

  def header_title
    content_tag(:h1, object.title, class: 'poll_title')
  end

  def truncate_title(default = 40)
    truncate(object.title.sub(/\n\n/, ' '), length: default)
  end

  def created_at
    object.created_at.strftime("%d %B %Y")
  end

  def get_rating_score
    if poll.vote_all == 0
      0
    else
      arr = object.choices.collect!{|e| e.answer.to_i * e.vote.to_f }
      arr.reduce(:+).to_f / poll.vote_all.to_f
    end
  end

  def get_top_vote
    object.get_vote_max.first["answer"]
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
    end
  end

  def lazy_photo_poll
    if photo_poll.present?
      image_tag("", data: { src: object.photo_poll.url(:thumbnail) }, class: 'lazy' )  
    end
  end

  def search_poll_image
    if photo_poll.present?
      image_tag(object.photo_poll.url(:thumbnail))  
    end
  end
  

end

