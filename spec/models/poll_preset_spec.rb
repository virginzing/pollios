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

require 'rails_helper'

RSpec.describe PollPreset, type: :model do

end
