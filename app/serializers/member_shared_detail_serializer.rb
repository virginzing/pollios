class MemberSharedDetailSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  attributes :info

  # def member_id
  #   object.id
  # end

  # def type
  #   object.member_type_text
  # end

  # def name
  #   object.fullname
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
    member_as_json = Member.serializer_member_hash( Member.cached_member(object) )
    member_as_json.merge({ "status" => entity_info })
  end

  def entity_info
    object.is_friend(options[:current_member]) if options[:current_member]
  end

end
