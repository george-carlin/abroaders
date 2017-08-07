module AdminArea
  class AdminsController < AdminController
    def index
      admins = Admin.all.order(id: :asc)
      render cell(AdminArea::Admins::Cell::Index, admins)
    end

    def new
      run AdminArea::Admins::New
      render cell(AdminArea::Admins::Cell::New, @model, form: @form)
    end

    def create
      run AdminArea::Admins::Create do
        flash[:success] = 'Created admin!'
        redirect_to admin_admins_path
        return
      end
      render cell(AdminArea::Admins::Cell::New, @model, form: @form)
    end

    def edit
      run Admins::Edit
      render cell(Admins::Cell::Edit, @model, form: @form)
    end

    def update
      run Admins::Update do
        flash[:success] = 'Update admin!'
        redirect_to admin_admins_path
        return
      end
      render cell(Admins::Cell::Edit, @model, form: @form)
    end
  end
end
