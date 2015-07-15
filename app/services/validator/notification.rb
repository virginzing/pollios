class Validator::Notification < ActiveModel::Validator
  def validate(record)
    unless record.notification.keys.uniq.sort == Member::Notification::DEFAULT.keys.uniq.sort
      fail ExceptionHandler::UnprocessableEntity, "Keys of notification don't match."
    end
  end
end
