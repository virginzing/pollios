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

end