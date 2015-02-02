class Company::MemberToGroup

  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(list_members, group)
    @list_members = list_members
    @group = group
  end

  def recipient_ids
    member_joined_group
  end

  def company_name
    @group.get_company.name
  end

  # allow 170 byte for custom message
  def custom_message
    message = "You joined in #{@group.name} of #{company_name} Company"
    truncate_message(message)
  end

  private

  def member_joined_group
    Member.where(id: @list_members).pluck(:id)
  end


  
end