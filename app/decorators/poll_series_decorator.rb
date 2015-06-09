class PollSeriesDecorator  < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


  def sum_average(sum_choice_vote)
    object.vote_all > 0 ? ( sum_choice_vote / object.vote_all ).round(2) : 0
  end

  def percent_average(sum_choice_vote)
    object.vote_all > 0 ? (((sum_choice_vote / object.vote_all ) * 100) /5.to_f).round(2) : 0
  end 

  def create_since
    content_tag(:span, nil , 'data-livestamp' => object.created_at.to_i)
  end

  def show_close_status
    if object.close_status
      content_tag :span, class: 'label label-info' do
        "Can't vote (Questionnaire closed)"
      end
    else
      content_tag :span, class: 'label label-success' do
        "Can vote (Questionnaire open)"
      end
    end
  end

  def show_allow_comment
    if object.allow_comment
      content_tag :span, class: 'label label-success' do
        "YES"   
      end
    else
      content_tag :span, class: 'label label-info' do
        "NO"   
      end
    end
  end

  def show_campaign
    if object.campaign.present?
      link_to campaign.name, company_campaign_detail_path(object.campaign, psId: object.id)
    else
      "-"
    end
  end

end