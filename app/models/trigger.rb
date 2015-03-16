class Trigger < ActiveRecord::Base
  store_accessor :data
  serialize :data, ActiveRecord::Coders::NestedHstore
  
  belongs_to :triggerable, polymorphic: true
end
