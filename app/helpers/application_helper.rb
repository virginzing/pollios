module ApplicationHelper

  def full_title(page_title = '')
    base_title = "Pollios"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def flash_class(level)
    case level
      when "notice" then "alert alert-warning"
      when "success" then "alert alert-success"
      when "error" then "alert alert-danger"
      else 'alert alert-info'
    end
  end

  def bread_crumb_using_service(request_path)
    str_path = request_path.split("/")[1]
    if str_path == "company"
      "Internal Survey"
    else
      str_path.titleize
    end
  end

  def convert_poll_url(activity)
    public_survey_poll_path(activity) if controller.class.parent == PublicSurveys
  end

  def current_controller?(options)
    url_string = CGI.escapeHTML(url_for(options))
    params = ActionController::Routing::Routes.recognize_path(url_string, :method => :get)
    params[:controller] == @controller.controller_name
  end

  def get_params_url(url)
    params = ""
    split_url = url.split("?")
    if split_url.size > 1
      params = '?' << url.split("?").last
    end
    params
  end

  def geneate_time
    return Time.now.to_i
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

  def cp(path)
    'active' if current_page?(path)
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
      index = tag.size.to_f / max.size * (classes.size - 1)
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
