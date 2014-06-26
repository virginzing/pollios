module NotificationsHelper
  HEART = HTMLEntities.new.decode "&#9829;"
  MALE = HTMLEntities.new.decode "&#9794;"
  FEMALE = HTMLEntities.new.decode "&#9792;"
  BOY = HTMLEntities.new.decode "&#128102;"
  GIRL = HTMLEntities.new.decode "&#128103;"
  TWOMEN = HTMLEntities.new.decode "&#128108;"
  TWOWOMEN = HTMLEntities.new.decode "&#128109;"
  MENANDWOMEN = HTMLEntities.new.decode "&#128107;"
  SPARKLINGHEART = HTMLEntities.new.decode "&#128150;"
  LOVELETTER = HTMLEntities.new.decode "&#128140;"
  DISAPPOINTED = HTMLEntities.new.decode "&#128542;"
  PRAY = HTMLEntities.new.decode "&#128591;"
  FEAR = HTMLEntities.new.decode "&#128561;"


  def truncate_message(message, truncate_default = 100, truncate_decentment = 2)
    begin
      custom_message = message.truncate(truncate_default)
      truncate_default = truncate_default - truncate_decentment
    end while custom_message.bytesize > 170

    add_double_quotation(custom_message)
  end

  def add_double_quotation(custom_message)
    last_word = custom_message.last.match(/"/)

    unless last_word.present?
      custom_message = custom_message + "\""
    end 
    
    custom_message
  end

end
