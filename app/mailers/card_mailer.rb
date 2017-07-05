class CardMailer < ApplicationMailer
  # opts: account_id, card_ids
  def annual_fee_reminder(opts = {})
    @account = Account.find(opts.fetch('account_id'))
    @cards = Card.accounts.unclosed.where(id: opts.fetch('card_ids'))
    mail to: @account.email, subject: 'Annual Fee Reminder'
  end
end
