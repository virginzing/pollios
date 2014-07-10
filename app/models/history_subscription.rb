class HistorySubscription < ActiveRecord::Base
  belongs_to :member

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

  def self.generate_day(product_id)
    case product_id
      when "com.codeapp.pollios.onemonth"
        return 30.days
      when "com.codeapp.pollios.oneyear"
        return 360.days
      else
        return 0.days
    end
  end

end
