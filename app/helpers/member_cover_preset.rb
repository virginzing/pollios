module MemberCoverPreset

  def hash_of_cover_preset
    hash = {}
    (1..25).each_with_index { |item, index| 
      hash[item] = rails_root + image_path + image_name(index + 1)
    }
    hash
  end

  def rails_root
    Rails.env.production? ? "http://codeapp-pollios.herokuapp.com" :  "http://localhost:3000"
  end

  def image_path
    "/images/cover_preset/"
  end

  def image_name(number_preset)
    "cover_preset_#{number_preset}" + ".jpg"
  end

  def get_cover_preset(number_preset)
    hash_of_cover_preset[number_preset]
  end

end