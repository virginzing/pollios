class Company::TrackActivityFeedGroup
  def initialize(member, group, action = params[:action])
    @member = member
    @group = group
    @action = action
  end

  def tracking
    @member.activity_feeds.create! action: @action, trackable: @group, group_id: @group.id
  end

end

