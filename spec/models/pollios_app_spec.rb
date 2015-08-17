# == Schema Information
#
# Table name: pollios_apps
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  app_id     :string(255)
#  expired_at :date
#  platform   :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe PolliosApp, type: :model do

end
