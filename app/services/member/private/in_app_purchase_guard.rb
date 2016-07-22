module Member::Private::InAppPurchaseGuard

  private

  def can_activate?
    return [false, GuardMessage::InAppPurchase.activated(receipt[:transaction_id])] if activated?
    return [false, GuardMessage::InAppPurchase.product_not_exist(receipt[:product_id])] if product_not_exist?

    [true, nil]
  end


  def activated?
    HistoryPurchase.exists?(transaction_id: receipt[:transaction_id])
  end

  def product_not_exist?
    product_details(receipt[:product_id]).nil?
  end

end