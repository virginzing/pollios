class PollCompany < ActiveRecord::Base
  include PollCompaniesHelper

  belongs_to :poll
  belongs_to :company

  def self.create_poll(poll, company, post_from)
    create!(poll: poll, company: company, post_from: post_from)
  end

end
