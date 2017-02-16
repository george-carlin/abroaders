module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      run(Person::Operation::Show)

      # TODO <% provide :title, @person.first_name %>

      render cell(Person::Cell::Show, result)
    end
  end
end
