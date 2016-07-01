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

def already_friend_message(a_member)
  "You and #{a_member.get_name} are already friends."
end

def already_sent_request_message(a_member)
  "You already sent friend request to #{a_member.get_name}."
end

def already_block_message(a_member)
  "You are currently blocking #{a_member.get_name}."
end

def already_follow_message
  "You already followed this account."
end

def already_block_message
  "You already blocked #{a_member.get_name}."
end

def add_themself_as_a_friend_message
  "You can't add yourself as a friend."
end

def unfriend_themself_message
  "You can't unfriend yourself."
end

def follow_themself_message
  "You can't follow yourself."
end

def unfollow_themself_message
  "You can't unfollow yourself."
end

def block_themself_message
  "You can't block yourself."
end

def unblock_themself_message
  "You can't unblock yourself."
end

def report_themself_message
  "You can't report yourself."
end

def not_friend_message(a_member)
  "You are not friends with #{a_member.get_name}."
end

def not_official_account_message
  "This member is not official account."
end

def not_following_message
  "You are not following this account."
end

def not_blocking_message(a_member)
  "You are not blocking #{a_member.get_name}."
end

def not_exist_incoming_request_message(a_member)
  "You don't have friend request from #{a_member.get_name}"
end

def friends_limit_exceed_message(a_member)
  "#{a_member.get_name} has over #{a_member.friend_limit} friends."
end

def accept_incoming_block_message
  "You can't accept this request at this moment."
end

def not_exist_incoming_request_message
  "This request is not existing."
end

def not_exist_outgoing_request_message
  "This request is not existing."
end