# == Schema Information
#
# Table name: invites
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  email      :string(255)
#  invitee_id :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Invite, :type => :model do

end
