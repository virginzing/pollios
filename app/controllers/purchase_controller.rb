class PurchaseController < ApplicationController

  protect_from_forgery :except => [:add_point]
  before_action :set_current_member, only: [:add_point]

  def add_point
    begin
    # receipt_data = RECEIPT #subscribe_params[:receipt_data]
    receipt_data = purchase_params[:receipt_data]
    member_id = purchase_params[:member_id]
    @add_point_count = 0

    puts "raw receipt data => #{receipt_data}"

    receipt = Itunes::Receipt.verify! receipt_data, :allow_sandbox  

    puts "receipt => #{receipt}"

    receipt.in_app.each do |rec|
      @purchase = HistoryPurchase.check_purchase(@current_member, rec)

      if @purchase
        @add_point_count = @add_point_count + 1
      end
    end

    puts "add point count => #{@add_point_count}"
    rescue => e
      render :json => {:response_status => "ERROR", :response_message => e.message }, :status => 400
    end

  end

  private


  def purchase_params
    params.permit(:member_id, :receipt_data)
  end


end
