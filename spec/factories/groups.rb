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

FactoryGirl.define do
  factory :group do
    name "Codeapp"
    group_type 0

    factory :group_with_cover_url do
      cover "http://res.cloudinary.com/code-app/image/upload/v1436275533/mkhzo71kca62y9btz3bd.png"
    end
  end

  factory :group_required, class: Group do
    member nil
    name Faker::Name.name
  end

  factory :group_optional, class: Group do
    member nil
    name Faker::Name.name
    description Faker::Lorem.sentence
    cover nil
    cover_preset 0
  end

  factory :group_public, class: Group, parent: :group_required do
    public true
  end

end
