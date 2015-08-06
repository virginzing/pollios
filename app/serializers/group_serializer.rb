# == Schema Information
#
# Table name: groups
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  public           :boolean          default(FALSE)
#  photo_group      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  authorize_invite :integer
#  description      :text
#  leave_group      :boolean          default(TRUE)
#  group_type       :integer
#  cover            :string(255)
#  admin_post_only  :boolean          default(FALSE)
#  need_approve     :boolean          default(TRUE)
#  public_id        :string(255)
#  visible          :boolean          default(TRUE)
#  system_group     :boolean          default(FALSE)
#  virtual_group    :boolean          default(FALSE)
#  member_id        :integer
#  cover_preset     :string(255)      default("0")
#  exclusive        :boolean          default(FALSE)
#  deleted_at       :datetime
#  opened           :boolean          default(FALSE)
#

class GroupSerializer < ActiveModel::Serializer
  self.root false

  attributes :id, :name, :photo

  def photo
    object.photo_group.url(:thumbnail)
  end

end
