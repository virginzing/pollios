class PollSeriesCompany < ActiveRecord::Base
  include PollSeriesCompaniesHelper

  belongs_to :poll_series
  belongs_to :company

  def self.create_poll_series(poll_series, company, post_from)
    create!(poll_series: poll_series, company: company, post_from: post_from)
  end

end
