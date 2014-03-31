class QrcodeSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :qrcode_key

  # def type
  #   object.series_text
  # end


end
