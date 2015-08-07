# == Schema Information
#
# Table name: poll_series_companies
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  company_id     :integer
#  post_from      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class PollSeriesCompany < ActiveRecord::Base
  include PollSeriesCompaniesHelper

  belongs_to :poll_series
  belongs_to :company

  def self.create_poll_series(poll_series, company, post_from)
    create!(poll_series: poll_series, company: company, post_from: post_from)
  end

end
