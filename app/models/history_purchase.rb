class HistoryPurchase < ActiveRecord::Base
  belongs_to :member

  def self.check_purchase(member, receipt)

    transaction_id = receipt["transaction_id"]
    product_id = receipt["product_id"]
    purchase_date = receipt["purchase_date"]

    even_purchase = true
    purchase_success = false

    purchase = where(transaction_id: transaction_id).first_or_initialize do |his_sub|
      even_purchase = false
      his_sub.member_id = member.id
      his_sub.product_id = product_id
      his_sub.transaction_id = transaction_id
      his_sub.purchase_date = purchase_date
      his_sub.save!
    end

    unless even_purchase
      if member.present?
        Member.transaction do
          purchase_success = true
          value, type = option_point(product_id)
          # puts "#{value}, #{type}"
          if type == 'P'
            new_point = member.point + value
            member.update!(point: new_point)
            purchase_success = true
          else
            if member.subscribe_last.nil?
              new_subscribe_expire = Time.zone.now + value
            else
              new_subscribe_expire = member.subscribe_expire + value
            end

            Member::ListFriend.new(member).follower.each do |follower|
              FlushCached::Member.new(follower).clear_list_friends
            end

            member.update!(member_type: :celebrity, subscription: true, subscribe_last: Time.zone.now, subscribe_expire: new_subscribe_expire, show_recommend: true)
          end
        end
      end
    end

    purchase_success
  end

  def self.check_subscribe(member, receipt)
    transaction_id = receipt.transaction_id
    product_id = receipt.product_id
    purchase_date = receipt.purchase_date

    even_subscribe = true

    subscribe = where(transaction_id: transaction_id).first_or_initialize do |his_sub|
      even_subscribe = false
      his_sub.member_id = member.id
      his_sub.product_id = product_id
      his_sub.transaction_id = transaction_id
      his_sub.purchase_date = purchase_date
      his_sub.save!
    end

    unless even_subscribe
      if member.subscribe_last.nil?
        new_subscribe_expire = Time.zone.now + self.generate_day(product_id)
      else
        new_subscribe_expire = member.subscribe_expire + generate_day(product_id)
      end
      member.update!(subscription: true, subscribe_last: Time.zone.now, subscribe_expire: new_subscribe_expire)
    end

  end

  def self.option_point(product_id)
    case product_id
      when "1publicpoll"
        return [1, 'P']
      when "5publicpoll"
        return [5, 'P']
      when "10publicpoll"
        return [10, 'P']
      when "1month"
        return [1.month, 'S']
      when "1year"
        return [1.year, 'S']
    end
  end

  def self.generate_day(product_id)
    case product_id
      when "1month"
        return 1.month
      when "1year"
        return 1.year
      else
        return 0.days
    end
  end

end
