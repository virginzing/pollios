module GroupApi
  module ClassMethods

  end

  module InstanceMethods
    def your_group
      @your_group ||= Member.list_group_active
    end

    def your_group_ids
      your_group.map(&:id)
    end

    def group_by_name
      # Hash[your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "cover" => f.get_cover_group, "virtual_group" => f.virtual_group]] }]
      Hash[your_group.map{ |group| [group.id, GroupDetailSerializer.new(group).as_json] }]
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
