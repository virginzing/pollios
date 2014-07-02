class Activity
  include SymbolHash
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  
  field :member_id, type: Integer
  field :items, type: Array

  index({ member_id: 1}, { unique: true, name: "member_id_index"})


  def self.create_activity_poll(member, poll, action)
    @member = member
    @poll = poll
    @action = action

    @hash_activity = manange_action_with_poll

    @find_activity = member_find_by_activity

    update_activity

    @find_activity
  end

  def self.create_activity_friend(member, friend, action)
    @member = member
    @friend = friend
    @action = action

    @hash_activity = manange_action_with_friend

    @find_activity = member_find_by_activity

    update_activity

    @find_activity
  end

  def self.create_activity_group(member, group, action)
    @member = member
    @group = group
    @action = action

    @hash_activity = manage_action_with_group

    @find_activity = member_find_by_activity

    update_activity

    @find_activity
  end

  def self.create_activity_my_self(member, action)
    @member = member
    @action = action

    @hash_activity = manage_action_my_self

    @find_activity = member_find_by_activity

    update_activity

    @find_activity
  end

  def self.member_find_by_activity
    member_activity = find_by(member_id: @member.id)
    unless member_activity.present?
      member_activity = create!(member_id: @member.id, items: [])
    end
    member_activity
  end

  def self.update_activity
    old_activity = @find_activity.items
    new_activity = old_activity.insert(0, @hash_activity)
    @find_activity.update!(items: new_activity)
  end

  def self.manange_action_with_poll
    if @action == ACTION[:vote]
      {
        poll: {
          id: @poll.id,
          title: @poll.title,
          created_at: @poll.created_at.to_i,
          public: @poll.public
        },
        creator: {
          member_id: @poll.member.id,
          name: @poll.member.fullname
        },
        authority: check_authority_poll,
        action: ACTION[:vote],
        type: TYPE[:poll],
        activity_at: Time.zone.now.to_i
      }
    elsif @action == ACTION[:create]
      {
        poll: {
          id: @poll.id,
          title: @poll.title,
          created_at: @poll.created_at.to_i,
          public: @poll.public
        },
        authority: check_authority_poll,
        action: ACTION[:create],
        type: TYPE[:poll],
        activity_at: Time.zone.now.to_i
      }
    else
      {
        poll: {
          id: @poll.id,
          title: @poll.title,
          created_at: @poll.created_at.to_i,
          public: @poll.public
        },
        authority: check_authority_poll,
        action: ACTION[:share],
        type: TYPE[:poll],
        activity_at: Time.zone.now.to_i
      }
    end
  end

  def self.manange_action_with_friend
    if @action == ACTION[:become_friend]
      {
        friend: {
          member_id: @friend.id,
          name: @friend.fullname
        },
        authority: AUTHORITY[:public],
        action: ACTION[:become_friend],
        type: TYPE[:friend],
        activity_at: Time.zone.now.to_i
      }
    else
      {
        friend: {
          member_id: @friend.id,
          name: @friend.fullname
        },
        authority: AUTHORITY[:public],
        action: ACTION[:follow],
        type: TYPE[:friend],
        activity_at: Time.zone.now.to_i
      }
    end
  end

  def self.manage_action_with_group
    if @action == ACTION[:join]
      {
        group: {
          id: @group.id,
          name: @group.name
        },
        action: ACTION[:join],
        type: TYPE[:group],
        activity_at: Time.zone.now.to_i
      }
    end
  end

  def self.manage_action_my_self
    action_change_name = ACTION[:change_name]
    action_change_avatar = ACTION[:chnage_avatar]
    type_member = TYPE[:member]

    if @action == action_change_name
      {
        member: {
          id: @member.id,
          name: @member.fullname
        },
        action: action_change_name,
        type: type_member,
        authority: AUTHORITY[:friend_following],
        activity_at: Time.zone.now.to_i
      }
    else
      {
        member: {
          id: @member.id,
          name: @member.fullname,
          avatar: @member.get_avatar
        },
        action: action_change_avatar,
        type: type_member,
        authority: AUTHORITY[:friend_following],
        activity_at: Time.zone.now.to_i
      }
    end
  end


  def self.check_authority_poll
    if @poll.in_group_ids == '0' ## not in group
      if @poll.public
        AUTHORITY[:public]
      else
        AUTHORITY[:friend_following]
      end
    else
      AUTHORITY[:group]
    end
  end

end
