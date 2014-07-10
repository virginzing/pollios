class HistoryPurchase < ActiveRecord::Base
  belongs_to :member

  def self.check_purchase(member, receipt)

    transaction_id = receipt.transaction_id
    product_id = receipt.product_id
    purchase_date = receipt.purchase_date

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
          new_point = member.point + option_point(product_id)
          member.update!(point: new_point)
          purchase_success = true
        end
      end
    end

    purchase_success
  end

  def self.option_point(product_id)
    case product_id
      when "com.codeapp.pollios.onepublicpoll"
        return 1
      when "com.codeapp.pollios.fivepublicpoll"
        return 5
      when "com.codeapp.pollios.tenpublicpoll"
        return 10
      else
        return 0
    end
  end

end
