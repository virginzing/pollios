# == Schema Information
#
# Table name: suggest_groups
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class SuggestGroup < ActiveRecord::Base

  def self.cached_all
    Rails.cache.fetch("suggest_groups") do 
      Group.where(id: SuggestGroup.all.pluck(:group_id)).to_a
    end
  end

  def self.flush_cached_all
    Rails.cache.delete("suggest_groups")
  end

end
