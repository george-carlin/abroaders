class CardAccountPresenter < ApplicationPresenter

  def render(&block)
    h.render "card_accounts/card_account", card_account: self, &block
  end

  def render_recommendation_actions
    h.render "card_accounts/recommendation_actions", card_account: self
  end

  # NOTE: If the card was added in the survey, we don't know the opened/closed
  # dates more precisely than the month. Eventually, when it becomes possible
  # to open/close recommended cards, we'll want to display the day of the month
  # for those cards ONLY.
  %i[closed_at opened_at].each do |meth|
    define_method meth do
      super()&.strftime("%b %Y") || "-"
    end
  end

  %i[applied_at clicked_at recommended_at].each do |meth|
    define_method meth do
      super()&.strftime("%D") || "-"
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
