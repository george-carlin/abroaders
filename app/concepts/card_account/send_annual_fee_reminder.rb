class CardAccount < CardAccount.superclass
  class SendAnnualFeeReminder
    def self.call
      unless Date.today.day == 1 || !!ENV['ANNUAL_FEE_REMINDER_TEST_MODE']
        raise "can't run unless today is the 1st of the month"
      end

      CardAccount::Query::AnnualFeeDue.().includes(
        :account, person: :account,
      ).group_by(&:account).each do |account, cards|
        card_ids = cards.map(&:id)
        CardMailer.annual_fee_reminder(
          account_id: account.id, card_ids: card_ids,
        ).deliver_later
      end
    end
  end
end
