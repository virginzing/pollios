class MemberSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  attributes :member_id, :type, :name, :username, :email, :avatar, :key_color, :status, :cover, :description

  def member_id
    object.id
  end

  def type
    object.member_type_text
  end

  def name
    object.sentai_name
  end

  def username
    object.username.present? ? object.username : ""
  end

  def email
    object.email
  end

  def avatar
    object.detect_image(object.avatar)
  end

  def key_color
    object.key_color.present? ? object.key_color : ""
  end

  def status
    object.is_friend(options[:user]) if options[:user]
  end

  def cover
    object.get_cover_image
  end

  def description
    object.description.present? ? object.description : ""
  end

end