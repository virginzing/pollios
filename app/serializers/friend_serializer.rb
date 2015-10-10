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

class FriendSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  # attributes :close_friend, :block_friend, :status

  attributes :status

  # def get_friend_info
  #   @friend_info ||= object.check_friend_entity(options[:user])
  # end

  def status
    object.is_friend(options[:user]) if options[:user]
  end

  # def close_friend
  #   get_friend_info[:close_friend]
  # end

  # def block_friend
  #   get_friend_info[:block_friend]
  # end

end
