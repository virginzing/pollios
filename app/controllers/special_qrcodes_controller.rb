class SpecialQrcodesController < ApplicationController
  layout 'admin'

  before_filter :set_special_qrcode, only: [:edit, :show, :update]

  def new
    @special_qrcode = SpecialQrcode.new
  end

  def index
    @special_qrcode = SpecialQrcode.all
  end


  def create
    @special_qrcode = SpecialQrcode.new(special_qrcode_params)

    if @special_qrcode.save
      flash[:success] = "Successfully created..."
      redirect_to admin_special_qrcode_path
    else
      flash[:error] = "Create fail"
      render 'new'
    end
  end

  def show
    # text_special_qrcode = Hash["code" => @special_qrcode.code, "type" => @special_qrcode.info["type"] ]
    @qr = RQRCode::QRCode.new(GenerateSpecialQrcodeLink.new(@special_qrcode.code, @special_qrcode.info["type"]).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url
  end

  def update
    if @special_qrcode.update!(special_qrcode_params)
      flash[:success] = "Successfully updated"
      redirect_to admin_special_qrcode_path
    else
      flash[:error] = "Update fail"
      redirect_to edit_special_qrcode_path(@special_qrcode)
    end
  end

  def edit
    
  end

  def destroy
    
  end


  private

  def set_special_qrcode
    @special_qrcode = SpecialQrcode.find(params[:id])
  end

  def special_qrcode_params
    params.require(:special_qrcode).permit(:code, :member_id, :type)
  end

end
