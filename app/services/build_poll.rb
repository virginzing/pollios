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
    if @params["expire_date"] == "0"
      Time.now + 100.years
    else
      Time.now + @params["expire_date"].to_i.days
    end
  end

  def title_with_tag
    @params["title_with_tag"].rstrip
  end

  def choice_freeform
    @choices_of_freeform = @options[:choices].collect{|value| value unless value.empty? }.compact
  end

  def type_poll
    @params["type_poll"]
  end

  def check_qr_only
    @params["qr_only"] == "on" ? true : false
  end

  def check_require_info
    @params["require_info"] == "on" ? true : false
  end

  def check_in_group
    @params["group_id"].present? ? true : false
  end

  def check_show_result
    @params["show_result"]  == "on" ? true : false
  end

  def set_poll_public
    if @member.celebrity? || @params["recurring_id"].present? || @member.brand?
      true
    else
      false
    end
  end

  def in_group_ids
    if @member.company?
      @params["group_id"]
    else
      "0"
    end
  end

  def check_allow_comment
    if @params["allow_comment"] == "on"
      true
    else
      false
    end
  end

  def list_of_choice
    @list_of_choice ||= list_choices
  end
  
  def poll_binary_params
    begin
      raise ExceptionHandler::MemberNotFoundHtml, "Member not found" unless @member.present?
      {
        "member_id" => @member.id,
        "title" => title_with_tag,
        "public" => set_poll_public,
        "series" => @series,
        "expire_date" => expire_date,
        "poll_series_id" => @poll_series_id,
        "campaign_id" => @params["campaign_id"],
        "recurring_id" => @params["recurring_id"],
        "type_poll" => @params["type_poll"],
        "in_group_ids" => in_group_ids,
        "photo_poll" => @params["photo_poll"],
        "status_poll" => 0,
        "member_type" => @member.member_type_text,
        "allow_comment" => check_allow_comment,
        "qr_only" => check_qr_only,
        "require_info" => check_require_info,
        "in_group" => check_in_group,
        "show_result" => check_show_result
      }
    end
  end

  def list_choices
    if type_poll == "binary"
      @choice_list << @params["choice_one"]
      @choice_list << @params["choice_two"]
      # @choice_list << "No vote"
    elsif type_poll == "freeform"
      @choice_list << @params["choice_one"]
      choice_freeform.each do |choice_freeform|
        @choice_list << choice_freeform
      end
      @choice_list
    else
      array_of_star = [1, 2, 3, 4, 5]
      array_of_star.each do |choice|
        @choice_list << choice        
      end
      @choice_list
    end
  end

  def build
      
  end

  def create
    
  end

end