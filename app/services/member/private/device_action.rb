module Member::Private::DeviceAction
  
  private

  def process_create(params)
    Apn::Device.create!(params)
  end

  def process_update_info(params)
    device.update!(params)

    Member::DeviceList.new(member).all_device
  end

  def process_delete
    device.destroy
    
    Member::DeviceList.new(member).all_device
  end

end