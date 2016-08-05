module Member::Private::InAppPurchase

  private

  def process_activate
    purchased_product = create_history_purchase
    product_value, product_type, product_name = product_details(purchased_product[:product_id])

    if product_type == :public_poll
      member_increase_point(product_value, product_name)
    elsif product_type == :subscription
      member_subscription(product_value, product_name)
    end
  end

  def create_history_purchase
    HistoryPurchase.create!(member_id: member.id \
      , product_id: receipt[:product_id] \
      , transaction_id: receipt[:transaction_id] \
      , purchase_date: receipt[:purchase_date])
  end

  def member_increase_point(purchased_point, product_name)
    member.update!(point: member.point + purchased_point)

    success_message(product_name)
  end

  def member_subscription(purchased_subscription, product_name)
    update_member_to_celebrity(purchased_subscription)
    clear_member_friends_followers_relation

    success_message(product_name)
  end

  def update_member_to_celebrity(purchased_subscription)
    member.update!(member_type: :celebrity \
      , subscription: true \
      , subscribe_last: Time.zone.now \
      , subscribe_expire: new_subscribe_expire(purchased_subscription) \
      , show_recommend: true)
  end

  def new_subscribe_expire(purchased_subscription)
    old_subscribe_expire = (not_subscribe_now? ? Time.zone.now : member.subscribe_expire)

    old_subscribe_expire + purchased_subscription
  end

  def not_subscribe_now?
    member.subscribe_last.nil? || member.subscribe_expire.nil?
  end

  def clear_member_friends_followers_relation
    clear_member_followers_cached
    clear_friends_of_member_friends_cached
  end

  def clear_member_followers_cached
    FlushCached::Member.new(member).clear_list_followers
  end

  def clear_friends_of_member_friends_cached
    Member::MemberList.new(member).followers.each do |friend|
      FlushCached::Member.new(friend).clear_list_friends
    end
  end

  def success_message(product_name)
    "Success Purchase: #{product_name}"
  end

  def product_details(product_id)
    case product_id
    when '1publicpoll'
      [1, :public_poll, '1 Public Poll']
    when '5publicpoll'
      [5, :public_poll, '5 Public Polls Pack']
    when '10publicpoll'
      [10, :public_poll, '10 Public Polls Pack']
    when '1month9.99'
      [1.month, :subscription, 'Monthly Subscription']
    when '1year99.99'
      [1.year, :subscription, 'Yearly subscription']
    end
  end
end