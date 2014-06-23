class GroupStats
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :stats_created_at, type: Date, default: Date.current
  field :amount_group, type: Integer, default: 0

  index( { stats_created_at: 1 }, { unique: true } )

  def self.create_group_stats(group)
    @group = group

    @stats_group = first_or_create_group_today

    update_stats_group_all   
  end

  def self.update_stats_group_all
    current_amount_group = @stats_group.amount_group
    
    @stats_group.update!(amount_group: current_amount_group + 1)
  end

  def self.find_stats_group_today
    GroupStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.filter_by(filtering)
    if filtering == 'today' 
      find_stats_group_today
    else
      find_stats_user_by(filtering)
    end
  end

  def self.first_or_create_group_today
    GroupStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.find_stats_group_today
    @group_stats = GroupStats.where(stats_created_at: Date.current).first_or_create!
    convert_stats_group_today_to_hash
  end

  def self.find_stats_user_by(condition)
    if condition == 'total'
      split(Group.all.to_a)
    else
      find_stats_group_today
    end
  end

  def self.convert_stats_group_today_to_hash
    {
      :amount => @group_stats.amount_group
    }
  end

  def self.split(list_of_user)
    new_hash = {}
    new_hash
  end

end
