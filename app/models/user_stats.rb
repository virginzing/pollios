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
    if filtering == 'total' 
      find_stats_user_total
    elsif filtering == 'yesterday'
      find_stats_user_yesterday
    elsif filtering == 'week'
      find_stats_user(7.days.ago.to_date)
    elsif filtering == 'month'
      find_stats_user(30.days.ago.to_date)
    else
      find_stats_user_today
    end
  end

  def self.first_or_create_user_today
    UserStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.find_celebrity_or_brand(end_date, start_date = Date.current)
    {
      citizen: Member.where("date(created_at + interval '7 hour') BETWEEN ? AND ?", end_date, start_date).member_type(:citizen).count,
      celebrity: Member.where("date(created_at + interval '7 hour') BETWEEN ? AND ?", end_date, start_date).member_type(:celebrity).count,
      brand: Member.where("date(created_at + interval '7 hour') BETWEEN ? AND ?", end_date, start_date).member_type(:brand).count
    }
  end

  def self.find_celebrity_or_brand_total
    {
      citizen: Member.member_type(:citizen).count,
      celebrity: Member.member_type(:celebrity).count,
      brand: Member.member_type(:brand).count
    }  
  end

  def self.find_celebrity_or_brand_yesterday
    {
      celebrity: Member.where("date(created_at + interval '7 hour') = ?", Date.current - 1.day).member_type(:celebrity).count,
      brand: Member.where("date(created_at + interval '7 hour') = ?", Date.current - 1.day).member_type(:brand).count 
    }
  end

  def self.find_stats_user_yesterday
    @user_stats = UserStats.where(stats_created_at: Date.current - 1.day).first_or_create!
    convert_stats_user_to_hash
  end

  def self.find_stats_user_today
    @user_stats = UserStats.where(stats_created_at: Date.current).first_or_create!
    convert_stats_user_to_hash
  end

  def self.find_stats_user_total
    split(Provider.select("member_id").distinct)
  end

  def self.find_stats_user(end_date, start_date = Date.current)
    query = Provider.joins(:member).select("providers.member_id").where("date(members.created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
    split(query)
  end

  def self.convert_stats_user_to_hash
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
end
