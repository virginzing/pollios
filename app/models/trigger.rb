# == Schema Information
#
# Table name: triggers
#
#  id               :integer          not null, primary key
#  triggerable_id   :integer
#  triggerable_type :string(255)
#  data             :hstore
#  created_at       :datetime
#  updated_at       :datetime
#

class Trigger < ActiveRecord::Base
  store_accessor :data
  serialize :data, ActiveRecord::Coders::NestedHstore
  
  belongs_to :triggerable, polymorphic: true
end
