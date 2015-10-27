module Pollios::V1
  class BaseEntity < Grape::Entity
    format_with(:as_integer) { |elem| elem.to_i }

    def self.expose_members(object_members, local_options = {})
      
      if local_options[:as]
        key = local_options[:as]
      else
        key = object_members
      end

      expose object_members, as: key do |obj, opts|

        members = obj.send object_members

        entity = Pollios::V1::Shared::MemberForListEntity
        if local_options[:entity]
          entity = local_options[:entity]
        end

        entity.represent members, current_member_linkage: current_member_linkage
      end
    end

  end
end