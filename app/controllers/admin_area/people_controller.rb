module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      run(Person::Operations::Show)

      @person        = result['person']
      @account       = @person.account
      @balances      = @person.balances.includes(:currency)

      card_scope = @person.cards.includes(product: :bank, offer: :product)
      @recommendation = card_scope.recommendations.build

      # until we've finished extracting show.html.erb, initializing the
      # incomplete cell here, pass it into the view, and use what we can.
      @cell = cell(AdminArea::Person::Cell::Show, result)
    end
  end
end
