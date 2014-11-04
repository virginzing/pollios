class Company::TrackActivityFeedPoll
  def initialize(member, group_ids, trackable, action = params[:action])
    @member = member
    @group_ids = group_ids
    @trackable = trackable
    @action = action
  end
  
  def split_group_id
    @group_ids.split(",").collect {|e| e.to_i }
  end

  def tracking
    split_group_id.each do |group_id|
      @member.activity_feeds.create! action: @action, trackable: @trackable, group_id: group_id
    end
  end
  
end