module V1::MenuHelper
  def active_menu?(current_page, menu_name)
    return 'active' if current_page == menu_name

    ''
  end
end
