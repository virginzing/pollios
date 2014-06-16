class UserStats
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :stats_created_at, type: Date, default: Date.current
  field :amount_user, type: Integer, default: 0
  field :via_facebook, type: Integer, default: 0
  field :via_sentai,   type: Integer, default: 0

  index( { stats_created_at: 1 }, { unique: true } )

  TYPE = {
    facebook: 'facebook',
    sentai: 'sentai'
  }

  def self.create_user_stats(user, via_type)
    @user = user
    @via_sentai = 0
    @via_facebook = 0
    @stats_user = find_stats_user_today

    if via_type == TYPE[:facebook]
      @via_facebook = 1
    else
      @via_sentai = 1
    end

    update_stats_all    
  end

  def self.update_stats_all
    current_amount_user = @stats_user.amount_user
    
    current_via_facebook = @stats_user.via_facebook
    
    current_via_sentai = @stats_user.via_sentai

    @stats_user.update!(amount_user: current_amount_user + 1, via_facebook: current_via_facebook + @via_facebook, via_sentai: current_via_sentai + @via_sentai)
  end

  def self.find_stats_user_today
    UserStats.where(stats_created_at: Date.current).first_or_create!
  end

end
