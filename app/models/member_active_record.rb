class MemberActiveRecord
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  
  field :stats_created_at, type: Date, default: Date.current
  field :list_member_ids, type: Array, default: []

  index( { stats_created_at: 1 }, { unique: true } )

  def self.record_member_active(member)
    find_today_record = where(stats_created_at: Date.current).first_or_create!
    unless find_today_record.list_member_ids.include?(member.id)
      find_today_record.update!(list_member_ids: find_today_record.list_member_ids << member.id)
    end
  end

end
