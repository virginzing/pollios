# == Schema Information
#
# Table name: friends
#
#  id           :integer          not null, primary key
#  follower_id  :integer
#  followed_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(TRUE)
#  block        :boolean          default(FALSE)
#  mute         :boolean          default(FALSE)
#  visible_poll :boolean          default(TRUE)
#  status       :integer
#  following    :boolean          default(FALSE)
#  close_friend :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :friend do
    follower nil
    followed nil

    trait :active do
      need_approve true
    end

    following false
  end

  factory :friend_required, class: Friend do
    follower nil
    followed nil
    status :friend
  end

  factory :friend_following, class: Friend, parent: :friend_required do
    status :nofriend
    following true
  end

  factory :friend_invite, class: Friend, parent: :friend_required do
    status :invite
    following false
  end

  factory :friend_invitee, class: Friend, parent: :friend_required do
    status :invitee
    following false
  end

end
