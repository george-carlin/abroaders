module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      run(Person::Operation::Show)

      render cell(Person::Cell::Show, result)
    end
  end
end
