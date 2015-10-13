module Pollios::V1
  class BaseSerializer < ActiveModel::Serializer

    include Pollios::V1::Shared::APIHelpers

    delegate :current_member, to: :scope

  end
end