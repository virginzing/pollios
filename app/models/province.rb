class Province < ActiveRecord::Base
  has_many :members, inverse_of: :province
end
