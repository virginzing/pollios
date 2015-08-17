# == Schema Information
#
# Table name: suggests
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  member_id      :integer
#  message        :text
#  created_at     :datetime
#  updated_at     :datetime
#

class Suggest < ActiveRecord::Base
  belongs_to :poll_series
  belongs_to :member
end
