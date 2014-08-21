class QrcodeSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :key, :series

  def key
    object.qrcode_key
  end
  
  def series
    object.class.name == "Poll" ? false : true
  end

end
