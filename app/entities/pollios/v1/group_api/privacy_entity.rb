module Pollios::V1::GroupAPI
  class PrivacyEntity < Pollios::V1::BaseEntity

    expose :public, if: -> (_, _) { admin_of_group? }
    expose :need_approve, if: -> (_, _) { admin_of_group? }
    expose :opened, if: -> (_, _) { admin_of_group? }
    expose :public_id

    private

    def group
      object
    end

    def current_member
      options[:current_member]
    end

    def admin_of_group?
      Group::MemberList.new(group).admin?(current_member)
    end

  end
end