module CardAccountsHelper

  def render_card_account(card_account, &block)
    render "card_accounts/card_account", card_account: card_account, &block
  end

end
