class Group::CoverPresetSelector
  def initialize(group)
    @group = group
  end

  def cover_preset
    @group.cover_preset
  end

  def path_group_cover_preset
    "/public/cover_group/"
  end

  def root_path_group_cover_preset
    Rails.root.to_s + path_group_cover_preset
  end

  def collection_group_cover_preset
    new_hash = {}

    Dir.foreach(root_path_group_cover_preset) do |file_name|
      scan_file_name = file_name.scan(/\d+/)
      if scan_file_name.size > 0
        new_hash.merge! Hash[ scan_file_name[0] => path_group_cover_preset + file_name ]
      end
    end

    new_hash
  end

  def show_cover_preset
    collection_group_cover_preset[cover_preset]
  end

end