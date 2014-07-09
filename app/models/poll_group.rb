class PollGroup < ActiveRecord::Base
  after_validation :report_validation_errors_to_rollbar
  belongs_to :poll
  belongs_to :group
  
end
