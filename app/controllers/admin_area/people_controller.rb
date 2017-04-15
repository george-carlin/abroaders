module AdminArea
  class PeopleController < AdminController
    # GET /admin/people/1
    def show
      person = Person.includes(
        unpulled_cards: { product: :bank },
        balances: :currency,
      ).find(params[:id])

      card_products = CardProduct.includes(
        :bank, :currency, :recommendable_offers,
      ).recommendable

      render cell(People::Cell::Show, person, card_products: card_products)
    end
  end
end
