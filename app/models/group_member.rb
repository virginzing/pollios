# == Schema Information
#
# Table name: group_members
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  group_id     :integer
#  is_master    :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(FALSE)
#  invite_id    :integer
#  notification :boolean          default(TRUE)
#

class GroupMember < ActiveRecord::Base
  include GroupMemberHelper

  belongs_to :member, touch: true
  belongs_to :group,  touch: true

  validates :member, presence: true
  validates :group, presence: true
  validate :admin_exist

  before_destroy { validate_sole_admin }

  def admin_exist
    errors.add(:group, 'must have at least one admin') unless will_be_sole_admin? || group_has_admin?
  end

  def validate_sole_admin
    return unless sole_admin?

    errors.add(:group, 'must have at least one admin')

    fail ExceptionHandler::Forbidden
  end

  def sole_admin?
    Group::MemberInquiry.new(group).sole_admin?(member)
  end

  def will_be_sole_admin?
    admin? && !Group::MemberInquiry.new(group).has_admin?
  end

  def admin?
    is_master
  end

  def group_has_admin?
    Group::MemberInquiry.new(group).has_admin?
  end

  def self.have_request_group?(group, member)
    find_by(group: group, member: member, active: false).present?
  end
end
