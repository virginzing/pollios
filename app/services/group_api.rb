module GroupApi
  module ClassMethods
    
  end
  
  module InstanceMethods
    def your_group
      @your_group ||= @member.cached_get_group_active
    end

    def your_group_ids
      your_group.map(&:id)
    end

    def group_by_name
      Hash[your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end