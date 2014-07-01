class BuildPoll
  def initialize(member_obj, params, options={})
    @member = member_obj
    @params = params
    @options = options
    @choice_list = []
    @series = false
    @poll_series_id = 0
  end

  def expire_date
    Time.now + @params["expire_date"].to_i.days
  end

  def title_with_tag
    @params["title_with_tag"].rstrip
  end

  def choice_freeform
    if @options["choices"]
      @options["choices"].collect! {|value| value unless value.blank? }.compact
    end
  end

  def type_poll
    @params["type_poll"]
  end

  def set_poll_public
    if @member.celebrity? || @params["recurring_id"].present? || @member.brand?
      true
    else
      false
    end
  end

  def list_of_choice
    @list_of_choice ||= list_choices
  end

  def choice_count
    list_of_choice.count
  end
  
  def poll_binary_params
    {
      "member_id" => @member.id,
      "title" => title_with_tag,
      "public" => set_poll_public,
      "series" => @series,
      "expire_date" => expire_date,
      "poll_series_id" => @poll_series_id,
      "choice_count" => choice_count,
      "campaign_id" => @params["campaign_id"],
      "recurring_id" => @params["recurring_id"],
      "type_poll" => @params["type_poll"],
      "in_group_ids" => "0",
      "photo_poll" => @params["photo_poll"],
      "status_poll" => 0
    }
  end

  def collect_of_rating
    
  end

  def list_choices
    if type_poll == "binary"
      @choice_list << @params["choice_one"]
      @choice_list << @params["choice_two"]
      @choice_list << "No vote"

    elsif type_poll == "freeform"
      @choice_list << @params["choice_one"]
      @choice_list << @params["choice_two"]
      @choice_list + choice_freeform
    else
      (1..5).each do |choice|
        @choice_list << choice        
      end
      @choice_list
    end
  end

end