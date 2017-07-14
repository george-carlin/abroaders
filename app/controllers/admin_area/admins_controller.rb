module AdminArea
  class AdminsController < AdminController
    def index
      admins = Admin.all.order(id: :asc)
      render cell(AdminArea::Admins::Cell::Index, admins)
    end
  end
end
