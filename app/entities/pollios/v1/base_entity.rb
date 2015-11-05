module Pollios::V1
  class BaseEntity < Grape::Entity

    format_with(:as_integer) { |elem| elem.to_i }
    format_with(:as_string) { |elem| elem.to_s }

    def self.expose_members(object_members, local_options = {})
      
      if local_options[:as]
        key = local_options[:as]
      else
        key = object_members
      end

      expose object_members, as: key do |obj, opts|

        members = obj.send object_members

        entity = Pollios::V1::Shared::MemberEntity
        if local_options[:entity]
          entity = local_options[:entity]
        end

        if local_options[:without_linkage]
          entity.represent members
        else
          entity.represent members, current_member_linkage: current_member_linkage
        end
      end
    end

    def self.expose_groups(object_groups, local_options = {})

      if local_options[:as]
        key = local_options[:as]
      else
        key = object_groups
      end

      expose object_groups, as: key do |obj, opts|
        groups = obj.send object_groups
        Pollios::V1::Shared::GroupEntity.represent groups
      end
    end

  end
end