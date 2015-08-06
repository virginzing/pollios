# == Schema Information
#
# Table name: api_tokens
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  token      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  app_id     :string(255)
#

require 'rails_helper'

RSpec.describe ApiToken, :type => :model do

end
