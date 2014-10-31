class CoverPreset
  include Mongoid::Document

  field :number_preset, type: Integer
  field :count, type: Integer, default: 1

  index( { number_preset: 1 }, { unique: true} )

  def self.count_number_preset(number_preset)
    find_cover_preset = CoverPreset.where(number_preset: number_preset).first

    if find_cover_preset.present?
      find_cover_preset.inc(count: 1) 
    else
      CoverPreset.create! number_preset: number_preset
    end

  end

end
