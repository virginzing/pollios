class Company::AddUserToGroup
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, group, company)
    @member = member
    @group = group
    @company = company
  end

  def recipient_ids
    @member.id
  end

  def custom_message
    message = "#{@company.name} Company added you to #{@group.name} Group"
    truncate_message(message)
  end

end