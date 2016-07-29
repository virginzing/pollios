class Member::InAppPurchase
  include Member::Private::InAppPurchaseGuard
  include Member::Private::InAppPurchase

  attr_reader :member, :receipt

  def initialize(member, receipt)
    @member = member
    @receipt = receipt.first
  end

  def activate
    can_activate, message = can_activate?
    fail ExceptionHandler::UnprocessableEntity, message unless can_activate

    process_activate
  end

end