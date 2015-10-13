module Pollios::V1::Shared::APIHelpers
  def attributes
    super.keep_if { |_, value| value.present? }
  end
end