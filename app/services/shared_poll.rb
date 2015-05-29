class SharedPoll

  def initialize(member, poll, options = nil)
    @member = member
    @poll = poll
    @options = options
  end

  def member_id
    @member.id    
  end

  def poll_id
    @poll.id
  end

  def list_group_id
    group_id = @options["group_id"]
    if group_id.present?
      groups = group_id.split(",").collect { |e| e.to_i }
    else
      groups = []
    end
    groups
  end

  def share
    @default_in_group = false
    if list_group_id.present?
      @default_in_group = true
      share_in_group
    else
      share_in_friend
    end
  end

  def unshare
    if list_group_id.present?
      unshare_in_group
    else
      unshare_in_friend
    end
  end

  def save_activity
    Activity.create_activity_poll(@poll.member, @poll, 'Share')
  end

  private

  def share_in_friend
    new_record = create_share

    if new_record
      record_shared_in_friend
    end
  end

  def share_in_group
    create_share
    record_shared_in_group
  end

  def create_share
    shared = false
    share = @poll.poll_members.where("member_id = #{member_id} AND share_poll_of_id = #{poll_id} AND in_group = ?", @default_in_group).first_or_create do |pm|
      pm.member_id = member_id
      pm.poll_id = poll_id
      pm.share_poll_of_id = poll_id
      pm.public = @poll.public
      pm.series = @poll.series
      pm.expire_date = @poll.expire_date
      pm.in_group = @default_in_group
      pm.save
      shared = true
    end
    shared
  end

  def record_shared_in_friend
    SharePoll.where(member_id: member_id, poll_id: poll_id, shared_group_id: 0).first_or_create do
      @poll.with_lock do
        @poll.share_count += 1
        @poll.save!
      end
    end
  end

  def record_shared_in_group
    list_group_id.each do |group_id|
      SharePoll.where(member_id: member_id, poll_id: poll_id, shared_group_id: group_id).first_or_create do
        @poll.with_lock do
          @poll.share_count += 1
          @poll.save!
        end
      end
      PollGroup.where(poll_id: poll_id, group_id: group_id, share_poll_of_id: poll_id, member_id: member_id).first_or_create!
    end
  end

  def unshare_in_friend
    find_shared_poll = SharePoll.find_by(member_id: member_id, poll_id: poll_id, shared_group_id: 0)
    find_shared_in_poll_member = PollMember.find_by(member_id: member_id, poll_id: poll_id, share_poll_of_id: poll_id, in_group: false)

    if find_shared_poll.present?
      if @poll.share_count > 0
        @poll.share_count -= 1
        @poll.save!
      end
      
      find_shared_poll.destroy
      find_shared_in_poll_member.destroy if find_shared_in_poll_member.present?
    end
  end

  def unshare_in_group
    list_group_id.each do |group_id|
      if @poll.share_count > 0
        @poll.share_count -= 1
        @poll.save!
      end
      find_shared_poll = SharePoll.find_by(member_id: member_id, poll_id: poll_id, shared_group_id: group_id)
      find_shared_poll_group = PollGroup.find_by(poll_id: poll_id, group_id: group_id, share_poll_of_id: poll_id, member_id: member_id)

      find_shared_poll.destroy if find_shared_poll.present?
      find_shared_poll_group.destroy if find_shared_poll_group.present?
    end

    if @poll.share_polls.where(member_id: member_id).empty?
      find_shared_in_poll_member = PollMember.find_by(member_id: member_id, poll_id: poll_id, share_poll_of_id: poll_id, in_group: true)
      find_shared_in_poll_member.destroy if find_shared_in_poll_member.present?
    end


  end


end

