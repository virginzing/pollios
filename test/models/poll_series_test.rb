# == Schema Information
#
# Table name: poll_series
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  description    :text
#  number_of_poll :integer
#  created_at     :datetime
#  updated_at     :datetime
#  vote_all       :integer          default(0)
#  view_all       :integer          default(0)
#  expire_date    :datetime
#  start_date     :datetime         default(2014-02-03 15:36:16 UTC)
#  campaign_id    :integer
#  share_count    :integer          default(0)
#  type_series    :integer          default(0)
#  type_poll      :integer
#  public         :boolean          default(TRUE)
#  in_group_ids   :string(255)      default("0")
#  allow_comment  :boolean          default(TRUE)
#  comment_count  :integer          default(0)
#  qr_only        :boolean
#  qrcode_key     :string(255)
#  require_info   :boolean
#  in_group       :boolean          default(FALSE)
#  recurring_id   :integer
#  feedback       :boolean          default(FALSE)
#  deleted_at     :datetime
#  expire_status  :boolean          default(FALSE)
#  close_status   :boolean          default(FALSE)
#

require 'test_helper'

class PollSeriesTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
