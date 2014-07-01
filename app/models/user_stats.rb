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
    @stats_user = first_or_create_user_today

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

  def self.filter_by(filtering)
    if filtering == 'today' 
      find_stats_user_today
    else
      find_stats_user_by(filtering)
    end
  end

  def self.first_or_create_user_today
    UserStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.find_celebrity_or_brand(start_date = Date.current)
    {
      celebrity: Member.where("date(created_at + interval '7 hour') = ?", start_date).member_type(:celebrity).count,
      brand: Member.where("date(created_at + interval '7 hour') = ?", start_date).member_type(:brand).count
    }
  end

  def self.find_stats_user_today
    @user_stats = UserStats.where(stats_created_at: Date.current).first_or_create!
    convert_stats_user_today_to_hash
  end

  def self.find_stats_user_by(condition)
    if condition == 'total'
      split(Provider.select("member_id").distinct)
    else
      find_stats_user_today
    end
  end

  def self.convert_stats_user_today_to_hash
    {
      :amount => @user_stats.amount_user,
      :facebook => @user_stats.via_facebook,
      :sentai => @user_stats.via_sentai
    }
  end

  def self.split(list_of_user)
    user_count ||= Provider.select("member_id").distinct.group("name").count
    {
      :amount => list_of_user.count,
      :facebook => user_count["facebook"],
      :sentai => user_count["sentai"]
    }
  end

  def self.top_voted_most
    Member.joins(:polls)
          .where("date(polls.created_at + interval '7 hours' ) = ?", Date.current)
          .select("members.*, sum(polls.vote_all) as vote_all")
          .group("members.id")
          .order("vote_all desc")
          .limit(10)
  end
end
