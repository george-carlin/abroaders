module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      run(People::Operation::Show)

      render cell(People::Cell::Show, result)
    end
  end
end
