class PollSeries::WebForm
  def initialize(member, params)
    @member = member
    @params = params
  end

  def check_poll_params
    @params["polls_attributes"].each do |key, value|
      if value["type_poll"] == "2"
        value["choices_attributes"] = new_choice_params_rating
      end
    end
  end

  def check_another_params
    if @params["allow_comment"] == "on"
      @params["allow_comment"] = true
    else
      @params["allow_comment"] = false
    end

    if @params["public"] == "on"
      @params["public"] = true
    else
      @params["public"] = false
    end

    if @params["require_info"] == "on"
      @params["require_info"] = true
    else
      @params["require_info"] = false
    end

    if @params["qr_only"] == "on"
      @params["qr_only"] = true
    else
      @params["qr_only"] = false
    end
  end

  def new_choice_params_rating
    hash = {}
    (1..5).to_a.each_with_index do |number, index|
      hash.merge!({
        index.to_s => {
          "answer" => number.to_s
        }
      })
    end
    hash    
  end

  def new_params
    check_another_params
    check_poll_params
    @params
  end


    
end