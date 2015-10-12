module Pollios::V1::Member
    class GroupListSerializer < ActiveModel::Serializer
      has_many :admin_of, :member_of

      def admin_of
        object.as_admin
      end

      def member_of
        object.as_member
      end
    end
end