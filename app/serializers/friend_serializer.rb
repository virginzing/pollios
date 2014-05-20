class FriendSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  attributes :close_friend, :block_friend

  def get_friend_info
    @friend_info ||= object.check_friend_entity(options[:user])
  end

  def close_friend
    get_friend_info[:close_friend]
  end

  def block_friend
    get_friend_info[:block_friend]
  end

end
