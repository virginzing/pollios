module PollHelper
  include ActionView::Helpers::NumberHelper

  def convert_to_percent(vote, vote_all)
    number_to_percentage((vote*100)/vote_all.to_f, precision: 0)
  end

  # def polls_30_days_ago_chart(start = 1.month.ago)
  #   polls_by_day = Poll.total_grouped_by_date(start)

  #   polls_friend_by_day = Poll.where("public = ? AND in_group_ids = ?", false, '0').total_grouped_by_date(start)

  #   polls_public_by_day = Poll.where("public = 't'").total_grouped_by_date(start)

  #   polls_group_by_day = Poll.where("public = ? AND in_group_ids != ?", false, '0').total_grouped_by_date(start)

  #   (start.to_date..Date.today).map do |date|
  #     {
  #       created_at: date,
  #       count: polls_by_day[date] || 0,
  #       poll_of_friend: polls_friend_by_day[date] || 0,
  #       poll_of_public: polls_public_by_day[date] || 0,
  #       poll_of_group: polls_group_by_day[date] || 0
  #     }
  #   end

  # end

  def show_star_answer(number_of_star)
    star_text = "<i class='fa fa-star'></i>"
    # p number_of_star
    case number_of_star.to_i
      when 1 then star_text*1
      when 2 then star_text*2
      when 3 then star_text*3
      when 4 then star_text*4
      when 5 then star_text*5
    end
  end

  def polls_ago_chart(end_date)
    (end_date.to_date..Date.current).map do |date|
      @query = Poll.unscoped.where("date(created_at + interval '7 hour') = ?", date).to_a
      {
        created_at: date,
        count: @query.size,
        poll_of_friend: @query.select{ |e| e.public == false && !e.in_group }.compact.size,
        poll_of_public: @query.select{ |e| e.public == true }.compact.size,
        poll_of_group: @query.select{ |e| e.public == false && e.in_group }.compact.size
      }
    end
  end

  def number_of_polls_created_today_chart(filtering)
    if filtering == "today" || filtering.nil?
      date = Date.current
    else
      date = Date.current - 1.day
    end
    query = Poll.unscoped.where("date(created_at + interval '7 hours') = ?", date).group("date_part('hour', created_at + interval '7 hours')").size
    map_each_hour(query)
  end

  def number_of_polls_voted_today_chart(filtering)
    if filtering == "today" || filtering.nil?
      date = Date.current
    else
      date = Date.current - 1.day
    end
    query = HistoryVote.unscoped.where("date(created_at + interval '7 hours') = ?", date).group("date_part('hour', created_at + interval '7 hours')").size
    map_each_hour(query)
  end

  def map_each_hour(list_hash_count)
    new_hash = {}

    list = (0..23).to_a.map do |e|
      list_hash_count.map do |k,v|
        query_hash = { hours: e, count: v }
        if k.to_i == e
          new_hash.merge(query_hash)
        else
          new_hash.merge({ hours: e, count: 0 })
        end
      end
    end
    list.flatten
  end

  def is_max_badge(vote, max)
    if vote == max && vote != 0
      'bg-color-red'
    end
  end

  def poll_that_image(poll)
    find_poll_photo = poll.photo_poll

    if find_poll_photo.present?
      content_tag :p do
        image_tag poll.photo_poll.url(:thumb_on_homepage)
      end
    end
  end

end
