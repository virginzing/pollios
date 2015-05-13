class Apn::PromoteAdmin
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(promoter, promotee, group)
    @promoter = promoter
    @promotee = promotee
    @group = group
  end

  def recipient_ids
    @promotee.id
  end

  def custom_message
    message = "#{@promoter.get_name} promoted you to administrator of #{@group.name} group"
    truncate_message(message)
  end

end
