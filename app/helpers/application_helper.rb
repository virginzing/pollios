module ApplicationHelper
  def flash_class(level)
      case level
        when "notice" then "alert alert-warning"
        when "success" then "alert alert-success"
        when "error" then "alert alert-danger"
        else 'alert alert-info'
      end
  end

  def current_controller?(options)
    url_string = CGI.escapeHTML(url_for(options))
    params = ActionController::Routing::Routes.recognize_path(url_string, :method => :get)
    params[:controller] == @controller.controller_name
  end

  def get_params_url(url)
    params = ""
    split_url = url.split("?")
    if split_url.count > 1
      params = '?' << url.split("?").last
    end
    params
  end

  def sum_average(list, number_branch, vote_count, index)
    new_list = list.each_slice(number_branch).to_a
    sum = (new_list.collect{|e| e[index] }.reduce(:+) / vote_count).round(2)
    sum = 0 if sum.nan?
    return sum
  end

  def percent_average(list, number_branch, vote_count, index)
    new_list = list.each_slice(number_branch).to_a
    sum = (((new_list.collect{|e| e[index] }.reduce(:+) / vote_count) * 100 ) / 5.to_f).round(2)
    sum = 0 if sum.nan?
    return sum
  end

  def rating_average(list, number, index)
    0
  end

  def maintenance_text(text)
    if text == "false"
      content_tag 'div', class: 'label label-danger' do
        "OFF"
      end
    else
      content_tag 'div', class: 'label label-success' do
        "ON"
      end
    end
  end

  def filter_helper(filter_by, options = nil)
    if filter_by == params[:filter_by]
      'active'
    elsif params[:filter_by].nil? && options.present?
      'active' unless params[:startdate].present?
    end
  end

  def get_icon_from_value(key)
    if key == "success"
      content_tag :i, :class => 'fa-fw fa fa-check' do
      end
    elsif key == "notice"
      content_tag :i, :class => 'fa-fw fa fa-info-circle' do
      end
    elsif key == "error"
      content_tag :i, :class => 'fa-fw fa fa-times' do
      end
    end
  end

  def convert_error_format(value)
    if value.class == Hash
      if value["email"].present?
        value["email"].first
      end
    else
      value
    end
  end

  def is_active_new_poll(c_name, a_name)
    if controller_name == c_name 
      if action_name == a_name
        'active'
      end
    end
  end

  def is_active_2nd_level(c_name, a_name)
    if controller_name == c_name
      if action_name == a_name
        'active'
      end
    end
  end

  def invite_code_helper(used)
    if used
      content_tag 'div', class: 'label label-success' do
        "Activated"
      end
    else
      content_tag 'div', class: 'label label-default' do
        "Not Active"
      end
    end
  end

  def manage_flash(flash, title = "", message = "", color = "", icon = "")
    if flash.present?
      flash.each do |name, msg|

        if name == "warning"
          title = "Warning"
          color = "#C46A69"
          icon  = "fa fa-warning"
        elsif name == "success"
          title = "Success"
          color = "#739E73"
          icon  = "fa fa-check"
        end

        message = msg
      end
    end
    [title, message, color, icon]
  end

  def is_active_3rd_level(c_name, a_name)
    if controller_name == c_name
      if (action_name == 'binary') || (action_name == 'rating') || (action_name == 'freeform')
        'active'
      elsif (action_name == 'normal') || (action_name == 'same_choice')
        'active'
      else
      end
    end
  end

  def active_class(name)
    if controller_name == name
      'active'
    end
  end

  def is_active?(name)
    controller_name == name ? 'active' : nil
  end

  def tag_clound(tags, classes)
    max = tags.sort_by(&:count).last
    tags.each do |tag|
      index = tag.count.to_f / max.count * (classes.size - 1)
      yield(tag, classes[index.round])
    end
    
  end

  def link_to_add_fields(name, f, association, class_name)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    class_name = class_name + " add_fields"
    link_to(name, '#', class: class_name, data: {id: id, fields: fields.gsub("\n", "")})
  end

  def qr_code(size, url)
    "https://chart.googleapis.com/chart?cht=qr&chld=l&chs=#{size}x#{size}&chl=#{url}"
  end


end


# curl -H "Content-Type: application/json" -d '{"member_id": 21, "friend_id": 50 }' -X POST http://localhost:3000/friend/following.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 6 }' -X POST http://localhost:3000/friend/unfollow.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 93 , "friend_id": 123 }' -X POST http://localhost:3000/friend/add_friend.json -i

 # curl -H "Content-Type: application/json" -d '{"member_id": 21, "friend_id": 30}' -X POST http://localhost:3000/friend/block.json -i
#  curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/add_close_friend.json -i
#  curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 2}' -X POST http://localhost:3000/friend/unclose_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 20, "friend_id": 21}' -X POST http://codeapp-pollios.herokuapp.com/friend/unblock.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 1, "friend_id": 3}' -X POST http://localhost:3000/friend/unmute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 93, "friend_id": 85 }' -X POST http://localhost:3000/friend/unfriend.json -i

# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 3}' -X POST http://localhost:3000/friend/mute_friend.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 85, "friend_id": 93 }' -X POST http://localhost:3000/friend/accept.json -i
# curl -H "Content-Type: application/json" -d '{"member_id": 2, "friend_id": 61 }' -X POST http://localhost:3000/friend/deny.json -i

# curl -H "Content-Type: application/json" -d '{
#     "ops": [
#         {
#             "method": "post",
#             "url": "/api/surveyor/questionnaires/survey",
#             "params": {
#                 "id": 74,
#                 "member_id": 179,
#                 "surveyed_id": 161,
#                 "answer": [
#                     {
#                         "id": "1455",
#                         "choice_id": "5276"
#                     },
#                     {
#                         "id": "1454",
#                         "choice_id": "5271"
#                     },
#                     {
#                         "id": "1453",
#                         "choice_id": "5266"
#                     },
#                     {
#                         "id": "1452",
#                         "choice_id": "5261"
#                     }
#                 ]
#             }
#         },
#         {
#             "method": "post",
#             "url": "/api/surveyor/questionnaires/survey",
#             "params": {
#                 "id": 74,
#                 "member_id": 179,
#                 "surveyed_id": 161,
#                 "answer": [
#                     {
#                         "id": "1455",
#                         "choice_id": "5276"
#                     },
#                     {
#                         "id": "1454",
#                         "choice_id": "5271"
#                     },
#                     {
#                         "id": "1453",
#                         "choice_id": "5266"
#                     },
#                     {
#                         "id": "1452",
#                         "choice_id": "5261"
#                     }
#                 ]
#             }
#         }
#     ],
#     "sequential": true
# }' -X POST http://localhost:3000/batchapi -i

# http://localhost:3000/friend/all.json?member_id=11
# http://localhost:3000/friend/request.json?member_id=15
# http://codeapp-pollios.herokuapp.com/friends/following.json?member_id=20
# http://localhost:3000/friend/search.json?member_id=21&q=Nuttapon

# curl -F "member_id=93" -F "name=Nutty Private Group 2" http://localhost:3000/group/build.json -i

# # curl -H "Content-Type: application/json" -d '{"member_id": 1, "group_id": 10 }' -X POST http://localhost:3000/group/delete_group.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 3, "group_id": 17 }' -X POST http://localhost:3000/group/deny_group.json -i
# # curl -H "Content-Type: application/json" -d '{"member_id": 2, "group_id": 17 }' -X POST http://localhost:3000/group/leave_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "group_id": 33,
#     "member_id": 1,
#     "friend_id": "2"
# }' -X POST http://localhost:3000/group/add_friend.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 86,
#     "message": "Same Same"
# }' -X POST http://localhost:3000/poll/755/comments.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 86,
#     "message": "dftyuiklfghjkl"
# }' -X POST http://localhost:3000/poll/752/comments.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 179
# }' -X POST http://localhost:3000/poll/1284/un_see.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 86
# }' -X DELETE http://localhost:3000/poll/752/comments/17.json -i


# Poll.update_all(comment_count: 0)


# curl -H "Content-Type: application/json" -d '{
#   "receipt": {
#     "receipt_type": "ProductionSandbox",
#     "original_purchase_date_ms": "1375340400000",
#     "original_purchase_date_pst": "2013-08-01 00:00:00 America/Los_Angeles",
#     "original_purchase_date": "2013-08-01 07:00:00 Etc/GMT",
#     "download_id": 0,
#     "request_date": "2014-07-22 14:31:34 Etc/GMT",
#     "request_date_ms": "1406039494269",
#     "in_app": [
#         {
#             "original_purchase_date_ms": "1406039483000",
#             "original_transaction_id": "1000000117614747",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "purchase_date_ms": "1406039483000",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "is_trial_period": "false",
#             "original_purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "5publicpoll",
#             "transaction_id": "1000000117614747",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT"
#         },
#         {
#             "original_purchase_date_ms": "1406030236000",
#             "original_purchase_date_pst": "2014-07-22 04:57:16 America/Los_Angeles",
#             "transaction_id": "1000000117594341",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 11:57:16 Etc/GMT",
#             "original_transaction_id": "1000000117594341",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "1month",
#             "purchase_date_ms": "1406039483000",
#             "expires_date": "2014-07-22 12:02:15 Etc/GMT",
#             "expires_date_ms": "1406030535000",
#             "web_order_line_item_id": "1000000028425926",
#             "is_trial_period": "false",
#             "expires_date_pst": "2014-07-22 05:02:15 America/Los_Angeles"
#         },
#         {
#             "original_purchase_date_ms": "1406030422000",
#             "original_purchase_date_pst": "2014-07-22 05:00:22 America/Los_Angeles",
#             "transaction_id": "1000000117594973",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 12:00:22 Etc/GMT",
#             "original_transaction_id": "1000000117594341",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "1month",
#             "purchase_date_ms": "1406039483000",
#             "expires_date": "2014-07-22 12:07:15 Etc/GMT",
#             "expires_date_ms": "1406030835000",
#             "web_order_line_item_id": "1000000028425927",
#             "is_trial_period": "false",
#             "expires_date_pst": "2014-07-22 05:07:15 America/Los_Angeles"
#         },
#         {
#             "original_purchase_date_ms": "1406030733000",
#             "original_purchase_date_pst": "2014-07-22 05:05:33 America/Los_Angeles",
#             "transaction_id": "1000000117596364",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 12:05:33 Etc/GMT",
#             "original_transaction_id": "1000000117594341",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "1month",
#             "purchase_date_ms": "1406039483000",
#             "expires_date": "2014-07-22 12:12:15 Etc/GMT",
#             "expires_date_ms": "1406031135000",
#             "web_order_line_item_id": "1000000028425933",
#             "is_trial_period": "false",
#             "expires_date_pst": "2014-07-22 05:12:15 America/Los_Angeles"
#         },
#         {
#             "original_purchase_date_ms": "1406031062000",
#             "original_purchase_date_pst": "2014-07-22 05:11:02 America/Los_Angeles",
#             "transaction_id": "1000000117597064",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 12:11:02 Etc/GMT",
#             "original_transaction_id": "1000000117594341",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "1month",
#             "purchase_date_ms": "1406039483000",
#             "expires_date": "2014-07-22 12:17:15 Etc/GMT",
#             "expires_date_ms": "1406031435000",
#             "web_order_line_item_id": "1000000028425945",
#             "is_trial_period": "false",
#             "expires_date_pst": "2014-07-22 05:17:15 America/Los_Angeles"
#         },
#         {
#             "original_purchase_date_ms": "1406031320000",
#             "original_purchase_date_pst": "2014-07-22 05:15:20 America/Los_Angeles",
#             "transaction_id": "1000000117597815",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 12:15:20 Etc/GMT",
#             "original_transaction_id": "1000000117594341",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "1month",
#             "purchase_date_ms": "1406039483000",
#             "expires_date": "2014-07-22 12:22:15 Etc/GMT",
#             "expires_date_ms": "1406031735000",
#             "web_order_line_item_id": "1000000028425962",
#             "is_trial_period": "false",
#             "expires_date_pst": "2014-07-22 05:22:15 America/Los_Angeles"
#         },
#         {
#             "original_purchase_date_ms": "1406031633000",
#             "original_purchase_date_pst": "2014-07-22 05:20:33 America/Los_Angeles",
#             "transaction_id": "1000000117598722",
#             "quantity": "1",
#             "original_purchase_date": "2014-07-22 12:20:33 Etc/GMT",
#             "original_transaction_id": "1000000117594341",
#             "purchase_date": "2014-07-22 14:31:23 Etc/GMT",
#             "purchase_date_pst": "2014-07-22 07:31:23 America/Los_Angeles",
#             "product_id": "1month",
#             "purchase_date_ms": "1406039483000",
#             "expires_date": "2014-07-22 12:27:15 Etc/GMT",
#             "expires_date_ms": "1406032035000",
#             "web_order_line_item_id": "1000000028425981",
#             "is_trial_period": "false",
#             "expires_date_pst": "2014-07-22 05:27:15 America/Los_Angeles"
#         }
#     ],
#     "request_date_pst": "2014-07-22 07:31:34 America/Los_Angeles",
#     "bundle_id": "com.code-app.Pollios-b2",
#     "adam_id": 0,
#     "application_version": "0.0.19-07-2014.1",
#     "original_application_version": "1.0"
# }
# }' -X POST http://localhost:3000/member/85/purchase_point.json -i


# curl -H "Content-Type: application/json" -d '{
#   "receipt_data": "dftyuiklfghjkl"
# }' -X POST http://localhost:3000/member/85/subscribe.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93,
#     "friend_id": "100"
# }' -X POST http://localhost:3000/group/101/invite.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 96
# }' -X POST http://localhost:3000/poll/785/watch.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 21,
#     "id": 143,
#     "qrcode_key": "46357f8468f1e92f9206071aceffa137"
# }' -X POST http://codeapp-pollios.herokuapp.com/scan_qrcode.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 2
# }' -X POST http://localhost:3000/group/13/leave.json -i



# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93
# }' -X POST http://localhost:3000/poll/1648/bookmark.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93
# }' -X POST http://localhost:3000/poll/16/un_bookmark.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 
# }' -X POST http://localhost:3000/group/51/accept.json -i

# curl -H "Content-Type: application/json" -d '{}'-X POST http://localhost:3000/poll/928/open_comment.json -i



# curl -H "Content-Type: application/json" -d '{
#     "friend_id": 47,
#     "message": "ภาพ cover เสื่อมมาก",
#     "block": true
# }' -X POST http://localhost:3000/member/21/report.json -i

# curl -H "Content-Type: application/json" -d '{
#     "username": "nuttapon509"
# }' -X POST http://localhost:3000/member/21/public_id.json -i

# curl -H "Content-Type: application/json" -d '{}' -X POST http://localhost:3000/member/63/request_code.json -i


# curl -H "Accept: application/vnd.pollios.v1" -H "Content-Type: application/json" -X GET "http://localhost:3000/api/group/65/polls?member_id=128" -i

# curl -H "Content-Type: application/json" -d '{
#     "txtUsername": "coconuzz",
#     "txtPassword": "mefuwfhfu",
#     "txtToken": "hOPpE2581f4v-0wMVbl3TLm0jbmnRPPRhV7pfNLjjNCIFvG_e_R_5WRm4jUSsk7V9YkUKB1SiLWDhoSZySbugXBadIW8XYcTWmFYsoYJM6pzyPn0Bb7zDzE3MzrphP19"
# }' -X POST http://54.255.131.200:80/account/login -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93,
#     "title": "​ทดสอบๆๆๆ Friend",
#     "choices": ["yes", "no", "no vote"],
#     "type_poll": "binary"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 21
# }' -X DELETE http://localhost:3000/poll/700/delete.json -i

# curl -F "member_id=1" -F "title=test" -F "expire_within=2" -F "type_poll=binary" -F "choices[]=1" -F "choices[]=2"  -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1, 
#     "title": "Friend 8 create two #lovely #Nuttapon My name is #eiei",
#     "expire_within": "5",
#     "choices": "1,2",
#     "type_poll": "freeform"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 9, 
#     "title": "No friend create poll",
#     "expire_within": "5",
#     "choices": "1,2,3",
#     "type_poll": "freeform"
# }' -X POST http://localhost:3000/poll/create.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 2, 
#     "title": "create in group 8 kub",
#     "expire_within": "1",
#     "choices": "yes,no",
#     "type_poll": "binary",
#     "group_id": "8"
# }' -X POST http://localhost:3000/poll/create.json -i

# PollMember.select(:poll_id ,:share_poll_of_id).where("member_id IN (?) AND share_poll_of_id != ?",[2,3], 0).group(:share_poll_of_id) | 
# PollMember.select(:poll_id).where("member_id = ? OR member_id IN (?) AND share_poll_of_id == 0",1,[2,3]).group(:poll_id).map(&:poll_id)

# PollMember.find_by_sql("SELECT pl.poll_id FROM poll_members pl LEFT JOIN poll_members pr ON pr.member_id IN (2,3) AND pl.poll_id > pr.poll_id AND (pl.share_poll_of_id = pr.poll_id OR pl.share_poll_of_id AND pl.share_poll_of_id = pr.share_poll_of_id) WHERE pr.poll_id IS NULL AND (pl.member_id = 1 OR pl.member_id IN (2,3)) ORDER BY pl.poll_id DESC LIMIT 20")

# PollMember.find_by_sql("SELECT pl.poll_id FROM poll_members pl LEFT JOIN poll_members pr ON pr.member_id IN (2,3) AND pl.poll_id > pr.poll_id")
# # Poll.joins(:poll_members).includes(:poll_series, :member).where("poll_members.poll_id < ? AND (poll_members.member_id IN (?) OR public = ?)", 2000, [1,2,3], true).order("poll_members.created_at desc")

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 86,
#     "message": "This is spam"
# }' -X POST http://localhost:3000/poll/758/report.json -i

# Tag.find_by_name("codeapp").polls.
# joins(:poll_members).
# where("(polls.public = ?) OR (poll_members.member_id = ? AND poll_members.in_group = ? AND poll_members.share_poll_of_id = 0)", true, 11, false)

# curl -H "Content-Type: application/json" -d '{
#   "member_id": 93,
#   "answer": [{"id": 1780, "choice_id": 6654}, {"id": 1779, "choice_id": 6649}, {"id": 1778, "choice_id": 6644}]
# }' -X POST http://localhost:3000/questionnaire/122/vote.json -i


# # http://localhost:3000/new_public_timeline.json?member_id=3

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93,
#     "choice_id": "7758"
# }' -X POST http://localhost:3000/poll/2027/vote.json -i


# curl -H "Content-Type: application/json" -d '{
#     "id": 72,
#     "member_id": 179,
#     "surveyed_id": 98,
#     "answer": [
#         {
#             "id": 1449,
#             "choice_id": 5246
#         },
#         {
#             "id": 1448,
#             "choice_id": 5241
#         }
#     ]
# }' -X POST http://localhost:3000/api/surveyor/questionnaires/survey -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93,
#     "list_survey": [
#         {
#             "poll_id": 1374,
#             "list_voted": [
#                 {
#                     "surveyed_id": 118,
#                     "choice_id": 4931
#                 }
#             ]
#         },
#         {
#             "poll_id": 0,
#             "list_voted": [
#                 {
#                     "surveyed_id": 93,
#                     "choice_id": 1100
#                 },
#                 {
#                     "surveyed_id": 91,
#                     "choice_id": 1101
#                 },
#                 {
#                     "surveyed_id": 94,
#                     "choice_id": 1102
#                 }
#             ]
#         }
#     ]
# }' -X POST http://localhost:3000/api/surveyor/polls/list_of_survey.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 30,
#     "group_id": "10"
# }' -X POST http://localhost:3000/poll/share/626.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 30,
#     "group_id": "10"
# }' -X POST http://localhost:3000/poll/unshare/626.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 100
# }' -X POST http://localhost:3000/group/102/request_group.json -i


# curl -H "Content-Type: application/json" -d '{
#     "member_id": 161
# }' -X POST http://localhost:3000/group/79/accept.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 93,
#     "friend_id": 100
# }' -X POST http://localhost:3000/group/102/accept_request_group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "guest_id": "1"
# }' -X POST http://localhost:3000/poll/33/view.json -i


# curl -H "Content-Type: application/json" -d '{
#     "email": "nuttapo111n@code-app.com"
# }' -X POST http://codeapp-pollios.herokuapp.com/member/verify_email.json -i

# curl -X GET http://localhost:3000/poll/public_timeline.json?member_id=1&api_version=5
# http://localhost:3000/poll/33/choices.json?guest_id=4&voted=no 

# http://localhost:3000/poll/tags.json?member_id=4
# http://localhost:3000/poll/guest_poll.json?guest_id=1

# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/group.json -i

# curl -H "Content-Type: application/json" -d '{
#     "email": "white@pollios.com",
#     "password": "123456",
#     "fullname": "White"
# }' -X POST http://pollios.com/authen/signup_sentai.json -i



# curl -H "Content-Type: application/json" -d '{
#     "member_id": "1"
# }' -X POST http://localhost:3000/poll/163/hide.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1,
#     "code": "CODEAPP",
#     "name": "facebook"
# }' -X POST http://localhost:3000/member/activate.json -i

# http://localhost:3000/member/profile.json?member_id=1
# Choice.find(39).update_attributes(vote: 76842)
# Poll.find(3).update(vote_all: 542388)

# Poll.find(12).choices.sum(:vote)
# Poll.find(12).update(view_all: 273122, vote_all: 236508)
# curl -H "Content-Type: application/json" -d '{"authen":"funnysmart_online@hotmail.com","password":"Nutty509", "app_id": "123" }' -X POST http://localhost:3000/authen/signin_sentai.json -i
# curl -F "email=krikri@gmail.com" -F "password=mefuwfhfu" -F "fullname=Kri Kri" -F "device_token=78916fe8 c0c342f0 3f2b6526 46fcf7b9 386c307d 2ac40035 25c1a045 74eda000" -X POST http://localhost:3000/authen/signup_sentai.json -i
# curl -F "sentai_id=64" -F "birthday=1990-01-15" -F "province_id=27" -X POST http://localhost:3000/authen/update_sentai.json -i


# curl -H "Content-Type: application/json" -d '{
# "authen":"nuttapon@code-app.com","password":"mefuwfhfu", "device_token": "12345678 c0c342f0 3f2b6526 46fcf7b9 386c307d 2ac40035 25c1a045 74eda000" 
# }' -X POST http://codeapp-pollios.herokuapp.com/authen/signin_sentai.json -i

# curl -H "Content-Type: application/json" -d '{
#     "udid": "0000"
# }' -X POST http://localhost:3000/guest/try_out.json -i

# curl -H "Content-Type: application/json" -d '{
#     "member_id": 1
# }' -X POST http://localhost:3000/campaigns/9/predict.json -i


# http://localhost:3000/campaigns/list_reward.json?member_id=1&api_version=5

# curl -F "member_id=179" -F "fullname=WelbackCome" -X POST http://localhost:3000/member/update_profile.json -i

# curl -H "Content-Type: application/json" -d '{
#     "id": "696969",
#     "email": "welback@gmail.com",
#     "name": "Welback",
#     "gender": 1
# }' -X POST http://localhost:3000/authen/facebook.json -i

# curl "http://localhost:3000/poll/93/overall_timeline.json?api_version=6" -H 'Authorization: Token token="4e029fd41cb01dd8a502bd359934eed"' -i

# curl -H "Content-Type: application/json" -d '{
#     "name": "1234567890",
#     "email": "1234567890@gmail.com"
# }' -X POST http://localhost:3000/authen/facebook.json -i


# curl -H "Content-Type: application/json" -d '{
#     "email": "nuttapon@code-app.com"
# }' -X POST http://localhost:3000/users_forgotpassword.json -i


# Member.all.each do |p|
#   if p.gender.nil?
#     p.gender = 0
#     p.save!
#   end
# end

# NotifyLog.where("custom_properties LIKE ?","%type: PollSeries%")

# 9494bda2 b735256f 2605a681 d5aed924 8ebf55e5 3c0f73df 5a085f80 7272e811
#db = Mongoid::Sessions.default

# connection = ActiveRecord::Base.connection
# ActiveRecord::Base.connection.execute(query)
# query = "SELECT r1.follower_id AS first_user, r2.follower_id AS second_user, COUNT(r1.followed_id) as mutual_friend_count FROM friends r1 INNER JOIN friends r2 ON r1.followed_id = r2.followed_id AND r1.follower_id != r2.follower_id WHERE r1.status = 1 AND r2.status = 1 AND r1.follower_id = 21 GROUP BY r1.follower_id, r2.follower_id"


#redis-server /usr/local/etc/redis.conf
