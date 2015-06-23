class PollPreset < ActiveRecord::Base
  validates_uniqueness_of :preset_id
end
