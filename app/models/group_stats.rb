class GroupStats
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :stats_created_at, type: Date, default: Date.today
  field :amount_group, type: Integer, default: 0

  index( { stats_created_at: 1 }, { unique: true } )

  def self.create_group_stats(group)
    @group = group

    @stats_group = find_stats_group_today

    update_stats_group_all   
  end

  def self.update_stats_group_all
    current_amount_group = @stats_group.amount_group
    
    @stats_group.update!(amount_group: current_amount_group + 1)
  end

  def self.find_stats_group_today
    GroupStats.where(stats_created_at: Date.today).first_or_create!
  end

end
