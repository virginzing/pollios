module Pollios::V1
  class BaseEntity < Grape::Entity
    format_with(:as_integer) { |elem| elem.to_i }
  end
end