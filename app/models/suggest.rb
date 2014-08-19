class Suggest < ActiveRecord::Base
  belongs_to :poll_series
  belongs_to :member
end
