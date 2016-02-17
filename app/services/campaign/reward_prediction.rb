class Campaign::RewardPrediction
  include Campaign::Private::RewardPredictionGuard

  attr_reader :member, :poll, :campaign

  def initialize(member, poll)
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
    create_member_reward(:waiting_announce, ref_no: generate_ref_no)
  end

  def random_reward
    reward_id = random_reward_id
    if reward_id == 0
      create_member_reward(:not_receive, ref_no: generate_ref_no)
      send_not_recive_reward_notification
    else
      increment_used_campaign_claimed_reward(reward_id)
      member_reward = create_member_reward(:receive, reward_id: reward_id \
        , serial_code: generate_serial_code, ref_no: generate_ref_no)
      send_recive_reward_notification(member_reward.id)
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

  def create_member_reward(reward_status, options = {})
    member.member_rewards.create!(poll_id: poll.id, campaign_id: campaign.id, reward_status: reward_status \
      , reward_id: options[:reward_id], serial_code: options[:serial_code], ref_no: options[:ref_no])
  end

  def random_from_voter
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

  def send_recive_reward_notification(member_reward_id)
    RewardWorker.perform_async(member_reward_id) unless Rails.env.test?
  end

  def send_not_recive_reward_notification
    NotReceiveRandomRewardPollWorker.perform_async(campaign.member_id, poll.id, [member.id] \
      , "Sorry! You don't get reward from poll: #{poll.title}") unless Rails.env.test?
  end

  # private

  def avilable_reward
    campaign.rewards.where('total > claimed').where('expire_at > ?', Time.now).order('rewards.id DESC')
  end

end