class HistoryViewQuestionnaire < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll_series
end
