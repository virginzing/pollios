module Pollios::V1::Member
    class GroupListSerializer < Pollios::V1::BaseSerializer

      has_many :admin_of, :member_of, :pending, each_serializer: Pollios::V1::Shared::GroupForListSerializer

      def admin_of
        object.as_admin
      end

      def member_of
        object.as_member
      end

      def pending
        object.inactive 
      end

    end
end