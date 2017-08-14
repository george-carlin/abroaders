module AdminArea::Offers
  # takes the ID of an offer, and the ID of a 'replacement' offer. Replacement
  # must be an 'alternative' offer, as defined in AA::Offers::AlternativesFor
  # for, or this operation will raise.
  #
  # When called, finds all *active* (i.e. unresolved) recs for the given Offer,
  # and changes their offer_id to point to the 'replacement'.
  #
  # 'model' will be set to the offer defined by the ':id' param.
  #
  # This op can't return a failing result. It will either succeed or raise an
  # error.
  #
  # @!method self.call(params = {}, options = {})
  #   @option params [Integer] :id
  #   @option params [Integer] :replacement_offer_id
  class Replace < Trailblazer::Operation
    success :process

    private

    def process(opts, params:, **)
      opts['model'] = offer = Offer.find(params[:id])
      replacement = offer.alternatives.find(params[:replacement_offer_id])
      ApplicationRecord.transaction do
        offer.active_recs.each { |rec| rec.update!(offer: replacement) }
      end
    end
  end
end
