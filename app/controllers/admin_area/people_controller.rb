module AdminArea
  class PeopleController < AdminController

    # GET /admin/people/1
    def show
      @person        = get_person
      @account       = @person.account
      @balances      = @person.balances.includes(:currencies)
      @card_accounts = @person.card_accounts.includes(:cards)
      @card_recommendation = @person.card_accounts.new
      # Use @person.card_accounts here instead of @card_accounts because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @cards = Card.where.not(id: @person.card_accounts.select(:card_id))
    end

    private

    def get_person
      Person.find(params[:id])
    end

  end
end
