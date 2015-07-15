class Validator::Notification < ActiveModel::Validator
  def validate(record)
    if record.notification.keys.sort != Member::Notification::DEFAULT.keys.sort
      fail ExceptionHandler::UnprocessableEntity, "Keys of Notification don't match."
    end
  end
end
