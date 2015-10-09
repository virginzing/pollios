module Pollios::V1::Shared
  class MemberForListSerializer < ActiveModel::Serializer
    attributes :id, :fullname
  end
end