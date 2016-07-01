# These methods are examples. Please kindly place new error message below these comments

# *** Note : please add /require 'guard_message'/ with no backslashes to the top of every action guard file.

# def address_not_exist_message
#   'คุณไม่มีที่อยู่นี้'
# end

# def address_name_already_exists_message(name)
#   "คุณมีที่อยู่ชื่อ #{name} แล้ว"
# end

# def invoice_not_exist_message
#   'คุณไม่มียอดค้างชำระสินค้านี้อยู่'
# end

# def product_already_favourited_message
#   'สินค้านี้โดนใจคุณไปแล้ว'
# end

# def insufficient_stock_message
#   'ปริมาณสินค้าที่จะเพิ่มไม่เพียงพอ'
# end
##########################

def member_already_in_group(member_name, group_name)
  "#{member_name} is already in #{group_name}."
end

def member_is_not_in_group(member_name, group_name)
  "#{member_name} is not a member in #{group_name}."
end

def no_join_request_from_member(member_name, group_name)
  "#{member_name} haven't sent any join request to #{group_name}."
end

def cant_remove_yourself
  'You cannot remove yourself.'
end

def member_is_group_creator(member_name)
  "#{member_name} is a group creator."
end

def member_already_admin(member_name)
  "#{member_name} is already an admin."
end

def member_is_not_admin(member_name)
  "#{member_name} is not an admin."
end
