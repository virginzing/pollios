class V5::MemberSerializer < ActiveModel::Serializer
  self.root false

  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end

  attr_accessor :options

  attributes :member_id, :type, :name, :username, :email, :avatar, :key_color, :cover, :description

  def member_id
    object.id
  end

  def type
    object.member_type_text
  end

  def name
    object.fullname
  end

  def username
    object.username.present? ? object.username : ""
  end

  def email
    object.email
  end

  def avatar
    object.avatar.present? ? object.avatar.url(:thumbnail) : ""
  end

  def key_color
    object.get_key_color
  end

  def cover
    object.get_cover_image
  end

  def description
    object.get_description
  end
  
end