# == Schema Information
#
# Table name: poll_companies
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  company_id :integer
#  post_from  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class PollCompany < ActiveRecord::Base
  include PollCompaniesHelper

  belongs_to :poll
  belongs_to :company

  def self.create_poll(poll, company, post_from)
    create!(poll: poll, company: company, post_from: post_from)
  end

end
