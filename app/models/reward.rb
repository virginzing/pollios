class Reward < ActiveRecord::Base
  belongs_to :campaign

  attr_accessor :unexpire
  
  def unexpired?
    ((reward_expire - created_at) / 1.year) > 80 ? true : false
  end

end
