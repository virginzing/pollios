module Pollios::V1
  class BaseEntity < Grape::Entity

    format_with(:as_integer, &:to_i)
    format_with(:as_string, &:to_s)

    def self.expose_members(object_members, local_options = {})
      if local_options[:as]
        key_name = local_options[:as]
      else
        key_name = object_members
      end

      expose object_members, as: key_name do |obj, _|

        if methods.include?(object_members)
          members = send object_members
        else
          members = obj.send object_members
        end

        if local_options[:entity]
          entity = local_options[:entity]
        else
          entity = Pollios::V1::Shared::MemberEntity
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
        key_name = local_options[:as]
      else
        key_name = object_groups
      end

      expose object_groups, as: key_name do |obj, _|
        groups = obj.send object_groups
        Pollios::V1::Shared::GroupEntity.represent groups
      end
    end

  end
end