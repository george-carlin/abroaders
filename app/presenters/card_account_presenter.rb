class CardAccountPresenter < ApplicationPresenter

  def render(&block)
    h.render "card_accounts/card_account", card_account: self, &block
  end

  def render_recommendation_actions
    h.render "card_accounts/recommendation_actions", card_account: self
  end

  %i[opened_at closed_at].each do |meth|
    define_method meth do
      super().strftime("%b %Y")
    end
  end


end
