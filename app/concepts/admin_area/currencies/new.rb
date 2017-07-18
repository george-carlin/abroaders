module AdminArea::Currencies
  # @!method self.call(params, options = {})
  class New < Trailblazer::Operation
    extend Contract::DSL

    contract do
      feature Reform::Form::Coercion

      property :name, type: Types::StrippedString
      property :type, type: Currency::Type.default('airline')
      property :alliance_name, type: Alliance::Name.default('Independent')

      validation do
        validates :name, presence: true
      end
    end

    step Model(Currency, :new)
    step :random_award_wallet_id
    step Contract::Build()

    private

    def random_award_wallet_id(model:, **)
      # currencies.award_wallet_id is non-nullable, even though we're not using
      # it yet, and we need to rethink the way we link currencies with AW in
      # general.  For now just create a random AW id for new currencies.
      model.award_wallet_id = SecureRandom.hex
    end
  end
end
