class GiftsController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token

  before_filter :authenticate_admin!

  def index
    @gift = GiftLog.all
  end

  def new
    @campaigns = Campaign.where(system_campaign: true)
    @gift = CampaignMember.new
  end

  def create
    init = System::Gift.new(gift_params, current_admin.id)

    gift_log = init.create_gift_log

    if gift_log
      AllGiftWorker.perform_async(gift_log.id)
      flash[:success] = "Send gift success"
      redirect_to gifts_path
    else
      flash[:error] = "Something went wrong"
      redirect_to new_gift_path
    end
  end

  private

  def gift_params
    params.require(:campaign_member).permit(:campaign_id, :list_member, :message)
  end
end
