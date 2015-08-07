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

class Invite < ActiveRecord::Base
  belongs_to :member
  belongs_to :invitee, class_name: "Member"

  validates :email, presence: true, :case_sensitive => false, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

end
