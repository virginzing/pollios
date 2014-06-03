class MemberSharedDetailSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  attributes :info, :entity_info

  # def member_id
  #   object.id
  # end

  # def type
  #   object.member_type_text
  # end

  # def name
  #   object.sentai_name
  # end

  # def username
  #   object.username.present? ? object.username : ""
  # end

  # def email
  #   object.email
  # end

  # def avatar
  #   object.detect_image(object.avatar)
  # end

  # def key_color
  #   object.get_key_color
  # end

  def info
    object.cached_member
  end

  def entity_info
    object.is_friend(options[:current_member]) if options[:current_member]
  end

end
