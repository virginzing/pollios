# == Schema Information
#
# Table name: history_view_questionnaires
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_series_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class HistoryViewQuestionnaire < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll_series
end
