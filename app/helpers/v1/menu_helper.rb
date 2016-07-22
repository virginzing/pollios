module V1
  module MenuHelper
    def active_menu?(current_page, menu_name)
      if current_page == menu_name
        return 'active'
      end

      ''
    end
  end
end