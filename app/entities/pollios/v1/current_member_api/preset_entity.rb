module Pollios::V1::CurrentMemberAPI
  class PresetEntity < Pollios::V1::BaseEntity
    expose :name
    expose :description, if: -> (obj, _) { obj[:description].present? }
    expose :choices
  end
end