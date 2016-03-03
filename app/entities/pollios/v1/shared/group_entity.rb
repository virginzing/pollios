module Pollios::V1::Shared
  class GroupEntity < Pollios::V1::BaseEntity

    expose :id, as: :group_id

    expose :member_count do |obj|
      Group::MemberList.new(obj).active.count
    end

    expose :name
    expose :description, if: -> (obj, _) { obj.description.present? }
    expose :get_cover_group, as: :cover, if: -> (obj, _) { obj.get_cover_group.present? }
    expose :cover_preset, unless: -> (obj, _) { obj.get_cover_group.present? }
    expose :type, if: -> (obj, _) { obj.company? } do |obj|
      obj.group_type.downcase
    end
    expose :admin_post_only
    expose :opened
    
    expose :status, if: -> (_, opts) { opts[:current_member_status].present? }

    private

    def status
      return :admin if admin?
      return :member if member?
      return :pending if pending?
      return :requesting if requesting?
      :outside
    end

    def relation
      options[:current_member_status]
    end

    def admin?
      relation[:admin_ids].include?(object.id)
    end

    def member?
      relation[:member_ids].include?(object.id)
    end

    def pending?
      relation[:pending_ids].include?(object.id)
    end

    def requesting?
      relation[:requesting_ids].include?(object.id)
    end
  end
end