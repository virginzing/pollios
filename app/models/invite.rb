class Invite < ActiveRecord::Base
  belongs_to :member
  belongs_to :invitee, class_name: "Member"

  validates :email, presence: true, :uniqueness => { :case_sensitive => false }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

end