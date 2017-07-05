# Preview all emails at http://localhost:3000/rails/mailers/card_mailer
#
# Useful guide: https://richonrails.com/articles/action-mailer-previews-in-ruby-on-rails-4-1
#
# To make these previews work, run rake ab:card_mailer_sample_data
#
# (Don't worry about whether the card accounts in the test data actually have
# their annual fee due; CardMailer just takes a list of pre-loaded cards and
# assumes that their fees are due.)
class CardMailerPreview < ActionMailer::Preview
  def annual_fee_reminder_solo
    account = solo_account
    CardMailer.annual_fee_reminder(
      'account_id' => account.id, 'card_ids' => account.cards.accounts.sample,
    )
  end

  def annual_fee_reminder_solo_multi
    account = solo_account
    CardMailer.annual_fee_reminder(
      'account_id' => account.id, 'card_ids' => account.cards.accounts,
    )
  end

  def annual_fee_reminder_couples
    account = couples_account
    CardMailer.annual_fee_reminder(
      'account_id' => account.id, 'card_ids' => account.cards.accounts.sample,
    )
  end

  def annual_fee_reminder_couples_multi
    account = couples_account
    CardMailer.annual_fee_reminder(
      'account_id' => account.id, 'card_ids' => account.cards.accounts,
    )
  end

  def annual_fee_reminder_couples_one_person
    account = couples_account
    CardMailer.annual_fee_reminder(
      'account_id' => account.id,
      'card_ids' => account.people.sample.cards.accounts.sample(2),
    )
  end

  private

  def solo_account
    Account.find_by_email!('card_mailer_test@example.com')
  end

  def couples_account
    Account.find_by_email!('card_mailer_test_couples@example.com')
  end

  def card_ids(account, count)
    account.cards.accounts.unclosed.sample(count).map(&:id)
  end
end
