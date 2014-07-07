class MemberSharedDetailSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  attributes :info

  def info
    @creator = object
    @find_member_cached = Member.cached_member(@creator)
    member_as_json = Member.serializer_member_hash(@find_member_cached)
    member_hash = member_as_json.merge( { "status" => entity_info } )
    member_hash
  end

  def entity_info
    @my_friend = Member.list_friend_active.map(&:id)
    @your_request = Member.list_your_request.map(&:id)
    @friend_request = Member.list_friend_request.map(&:id)
    @my_following = Member.list_friend_following.map(&:id)
    
    if @my_friend.include?(@creator.id)
      hash = Hash["add_friend_already" => true, "status" => :friend]
    elsif @your_request.include?(@creator.id)
      hash = Hash["add_friend_already" => true, "status" => :invite]
    elsif @friend_request.include?(@creator.id)
      hash = Hash["add_friend_already" => true, "status" => :invitee]
    else
      hash = Hash["add_friend_already" => false, "status" => :nofriend]
    end

    if @creator.celebrity? || @creator.brand?
      @my_following.include?(@creator.id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
    else
      hash.merge!({"following" => "" })
    end
    hash
  end

end