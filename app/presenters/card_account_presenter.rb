class CardAccountPresenter < ApplicationPresenter
  # If the card account was added in the onboarding survey (as opposed to
  # being recommended to the user by an admin), we only know the month
  # and year that the account was opened/closed, and not the precise date. However,
  # because the DB needs a full date to be stored, we're saving these dates
  # as the first of the month. So if the card was added in the onboarding survey,
  # only show e.g. "Jan 2016", otherwise show "01/01/2016"
  %i[closed_at denied_at opened_at].each do |meth|
    define_method meth do
      if recommendation?
        super()&.strftime("%D")
      else
        super()&.strftime("%b %Y")
      end
    end
  end

  %i[applied_at seen_at clicked_at declined_at recommended_at pulled_at].each do |meth|
    define_method meth do
      super()&.strftime("%D")
    end
  end

  %i[closed_at opened_at applied_at recommended_at].each do |meth|
    define_method "#{meth}_value".to_sym do
      self[meth]
    end
  end

  delegate :name, :identifier, :currency, :bank_name, to: :card, prefix: true

  def status
    super().humanize
  end

  def card_bp
    card.bp.to_s.capitalize
  end

  def card
    @card ||= CardPresenter.new(super, view)
  end

  def offer
    @offer ||= super.present? ? OfferPresenter.new(super, view) : nil
  end
end
