class Trigger < ActiveRecord::Base
  # store_accessor :data
  belongs_to :triggerable, polymorphic: true
end
