class Province < ActiveRecord::Base
  # has_many :members, inverse_of: :province

  # def self.get_province_list
  #   @load_province_cached = Rails.cache.fetch('provinces') do
  #     Province.all.to_a
  #   end
  #   results = @load_province_cached.collect{|e| { e.name => e.id } }
  #   return results
  # end

end
