# == Schema Information
#
# Table name: campaigns
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  photo_campaign  :string(255)
#  used            :integer          default(0)
#  limit           :integer          default(0)
#  member_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  begin_sample    :integer          default(1)
#  end_sample      :integer
#  expire          :datetime
#  description     :text
#  how_to_redeem   :text
#  company_id      :integer
#  type_campaign   :integer
#  redeem_myself   :boolean          default(FALSE)
#  reward_info     :hstore
#  reward_expire   :datetime
#  system_campaign :boolean          default(FALSE)
#  announce_on     :datetime
#

require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
