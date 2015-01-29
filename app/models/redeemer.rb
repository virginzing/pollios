class Redeemer < ActiveRecord::Base
  belongs_to :company
  belongs_to :member
end
