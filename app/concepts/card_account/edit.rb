class CardAccount < CardAccount.superclass
  # Find a CardAccount by its ID, and prepare to edit it
  class Edit < Trailblazer::Operation
    extend Contract::DSL
    contract CardAccount::Form

    step :setup_model!
    step Contract::Build()

    private

    def setup_model!(options, params:, **)
      options['model'] = card_scope.includes(:person).find(params[:id])
    end

    # Where to search for the card account. Must return an object which responds to
    # `find`. By default, returns the account's cards, but you can override
    # this with the 'card_scope' skill (e.g. you could set it to `CardAccount` if
    # you want to search *all* cards for an admin action.)
    def card_scope(*)
      self['card_scope'] || self['current_account'].card_accounts
    end
  end
end
