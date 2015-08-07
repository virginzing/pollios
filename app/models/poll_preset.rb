# == Schema Information
#
# Table name: poll_presets
#
#  id         :integer          not null, primary key
#  preset_id  :integer
#  name       :string(255)
#  count      :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class PollPreset < ActiveRecord::Base
  validates_uniqueness_of :preset_id
end
