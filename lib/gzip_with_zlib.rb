module GzipWithZlib

  def decompress_zlib(data)
    decode64 = Base64.urlsafe_decode64(data)
    inflate = Zlib::Inflate.inflate(decode64)
    json = JSON.parse(inflate)
    # puts "decompress = #{json}"
    return json
  end

  def compress_zlib(data)
    string_of_data = data.to_json
    deflate = Zlib::Deflate.deflate(string_of_data)
    encode64 = Base64.urlsafe_encode64(deflate)
    # puts "compress = #{encode64}"
    return encode64
  end

end
