class Trigger::BuildTrigger
  def initialize(params)
    @params = params
  end

  def poll
    Poll.cached_find(@params["poll_id"])
  end

  def choice_with_group_id
    list = []

    @params["choice"].each do |k, v|
      list << Hash["choice_id" => k.to_i, "group_id" => v.to_i ]
    end

    list
  end

  def poll_as_json
    hash = {}
    hash.merge!(@params["triggers"]["data"])
    hash.merge!({
      poll_id: @params["poll_id"]
    })
    hash.merge!({
      condition: choice_with_group_id
    })
    hash
  end

  def setup
    Trigger.create!(triggerable: poll, data: poll_as_json)
  end
  
end