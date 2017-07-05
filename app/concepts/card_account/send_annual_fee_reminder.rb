class CardAccount < CardAccount.superclass
  class SendAnnualFeeReminder
    def self.call
      unless Date.today.day == 1 || test_mode?
        raise "can't run unless today is the 1st of the month"
      end

      CardAccount::Query::AnnualFeeDue.().includes(
        :account, person: :account,
      ).group_by(&:account).each do |account, cards|
        next if test_mode? && !account.test?
        card_ids = cards.map(&:id)
        CardMailer.annual_fee_reminder(
          account_id: account.id, card_ids: card_ids,
        ).deliver_later
      end
    end

    # Activating test mode makes two things happen:
    # - non-test accounts won't receive any emails
    # - this op can be run if today is not the first day of the month.
    def self.test_mode?
      !!ENV['ANNUAL_FEE_REMINDER_TEST_MODE']
    end
  end
end
