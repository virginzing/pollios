class Campaign::RewardPrediction
  include Campaign::Private::RewardPredictionGuard

  attr_reader :member, :poll, :campaign

  def initialize(member = nil, poll)
    @member = member
    @poll = poll
    @campaign = poll.campaign

    can_predict, message = can_predict?
    return message unless can_predict
    predict
  end

  def predict
    if campaign.random_later?
      random_reward_later
    else
      random_reward
    end
  end

  def random_reward_later
    create_member_reward(:waiting_announce, member.id)
  end

  def random_reward
    reward_id = random_reward_id
    if reward_id == 0
      create_member_reward(:not_receive, member.id)
      send_not_receive_reward_notification(member.id.to_a)
    else
      increment_used_campaign_claimed_reward(reward_id)
      member_reward = create_member_reward(:receive, member.id, reward_id: reward_id \
        , serial_code: generate_serial_code)
      send_receive_reward_notification(member_reward.id)
    end
  end

  def random_reward_id
    avilable_reward.each do |reward|
      return reward.id if (1..reward.odds).to_a.sample % reward.odds == 0
    end
    0
  end

  def increment_used_campaign_claimed_reward(reward_id)
    campaign.with_lock do
      campaign.used += 1
      campaign.save!
    end

    reward = Reward.find(reward_id)
    reward.with_lock do
      reward.claimed += 1
      reward.save!
    end
  end

  def create_member_reward(reward_status, member_id, options = {})
    campaign.member_rewards.create!(reward_status: reward_status, poll_id: poll.id \
      , member_id: member_id, reward_id: options[:reward_id] \
      , serial_code: options[:serial_code], ref_no: generate_ref_no)
  end

  def random_from_voter
    voter_ids = poll.history_votes.map(&:member_id)

    avilable_reward.each do |reward|
      member_get_reward_ids = voter_ids.sample(reward.total)

      member_get_reward_ids.each do |member_id|
        member_reward = campaign.member_rewards.find_by(member_id: member_id)
        member_reward.update!(reward_status: :receive, reward_id: reward.id, serial_code: generate_serial_code)
        increment_used_campaign_claimed_reward(reward.id)
        send_receive_reward_notification(member_reward.id)
      end

      voter_ids -= member_get_reward_ids
    end

    voter_ids.each do |member_id|
      member_reward = campaign.member_rewards.find_by(member_id: member_id)
      member_reward.update!(reward_status: :not_receive)

      send_receive_reward_notification(member_reward.id)
    end
  end

  def generate_serial_code
    serial_code = ('S' + SecureRandom.hex(6)).upcase
    return serial_code unless MemberReward.exists?(serial_code: serial_code)
    serial_code
  end

  def generate_ref_no
    ref_no = ('R' + SecureRandom.hex(6)).upcase
    return ref_no unless MemberReward.exists?(ref_no: ref_no)
    ref_no
  end

  def send_receive_reward_notification(member_reward_id)
    V1::Reward::ReceiveWorker.perform_async(member_reward_id) unless Rails.env.test?
  end

  # private

  def avilable_reward
    campaign.rewards.where('total > claimed').where('expire_at > ?', Time.now).order('rewards.id DESC')
  end

end