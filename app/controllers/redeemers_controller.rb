class RedeemersController < ApplicationController

  decorates_assigned :member

  before_action :signed_user
  before_action :load_company
  before_action :check_using_service
  before_action :set_redeemer, only: [:edit, :uddate, :destroy]

  def index
    @redeemers = @company.get_redeemers
  end

  def new
    @member = Member.new
  end

  def create

  end

  def edit

  end

  def update

  end

  def destroy

  end

  private

  def set_redeemer
    @redeemer = Redeemer.find(params[:id])
  end
end
