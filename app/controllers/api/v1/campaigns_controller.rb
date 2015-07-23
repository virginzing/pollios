module Api
  module V1

    class CampaignsController < ApplicationController

      def redeem_code
        @redeem = CampaignMember.with_reward_status(:receive).find_by(serial_code: redeem_code_params[:serial_code])

        respond_to do |wants|

          if @redeem.present?
            if @redeem.redeem
              wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "You already use this serial code"], status: 422 }
            else
              @redeem.update!(redeem: true, redeem_at: Time.zone.now, redeemer_id: redeem_code_params[:redeemer_id])

              @campaign_detail = @redeem.campaign.as_json()
              @member_detail = @redeem.member.as_json()

              wants.json { render json: Hash["response_status" => "OK", "campaign" => @campaign_detail, "member_detail" =>  @member_detail, "response_message" => "Redeem sucessfully"] }
            end
          else
            wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "Serial code not found"], status: 404 }
          end
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
      def set_campaign
        @campaign = Campaign.find(params[:id])
      end

      def redeem_code_params
        params.permit(:serial_code, :redeemer_id)
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def campaign_params
        params.require(:campaign).permit(:name, :photo_campaign, :used, :limit, :begin_sample, :end_sample, :poll_ids, :expire, :poll_id, :description, :how_to_redeem)
      end

    end
  end
end
