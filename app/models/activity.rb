class Activity
  include Mongoid::Document
  field :member_id, type: Integer
  field :items, type: Array

  index({ member_id: 1}, { unique: true, name: "member_id_index"})

  TYPE = {
    :poll => 'Poll',
    :friend => 'Friend',
    :group => 'Group'
  }

  ACTION = {
    :vote => 'Vote',
    :create => 'Create',
    :share => 'Share',
    :become_friend => 'BecomeFriend',
    :follow => 'Follow',
    :join => 'Join'
  }

  AUTHORITY = {
    :public => 'Public',
    :friend_following => 'Friends & Following',
    :group => 'Group',
    :private => 'Private'
  }

  def self.create_activity_poll(member, poll, action)
    @member = member
    @poll = poll
    @action = action

    hash_activity = manange_action_with_poll

    find_activity = find_by(member_id: @member.id)

    if find_activity.present?
      old_activity = find_activity.items
      new_activity = old_activity.insert(0, hash_activity)
      find_activity.update!(items: new_activity)
    else
      create!(member_id: @member.id, items: [hash_activity])
    end
    find_activity
  end

  def self.create_activity_friend(member, friend, action)
    @member = member
    @friend = friend
    @action = action

    hash_activity = manange_action_with_friend
    find_activity = find_by(member_id: @member.id)

    if find_activity.present?
      old_activity = find_activity.items
      new_activity = old_activity.insert(0, hash_activity)
      find_activity.update!(items: new_activity)
    else
      create!(member_id: @member.id, items: [hash_activity])
    end
    find_activity
  end

  def self.manange_action_with_poll
    if @action == ACTION[:vote]
      {
        poll: {
          id: @poll.id,
          question: @poll.title,
          created_at: @poll.created_at.to_i,
          public: @poll.public
        },
        creator: {
          id: @poll.member.id,
          name: @poll.member.sentai_name
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
          question: @poll.title,
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
          question: @poll.title,
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
          id: @friend.id,
          name: @friend.sentai_name
        },
        authority: AUTHORITY[:public],
        action: ACTION[:become_friend],
        type: TYPE[:friend],
        activity_at: Time.zone.now.to_i
      }
    else
      {
        friend: {
          id: @friend.id,
          name: @friend.sentai_name
        },
        authority: AUTHORITY[:public],
        action: ACTION[:follow],
        type: TYPE[:friend],
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
