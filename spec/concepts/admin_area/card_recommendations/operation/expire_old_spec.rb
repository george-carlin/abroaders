require 'rails_helper'

module AdminArea
  # don't forget to rename this file
  RSpec.describe CardRecommendations::Operation::ExpireOld do
    let(:person) { create(:person) }
    let(:offer)  { create_offer }
    let(:now) { Time.zone.now }

    let(:op) { described_class }

    example '.call' do
      lose = 16.days.ago
      keep = 15.days.ago + 1.minute

      # use the 'real' operation to create the rec, then update the
      # rest of the attrs manually:
      def create_rec(attrs = {})
        result = CardRecommendations::Operation::Create.(
          # use the same person/offer every time to reduce DB queries
          person_id: person.id,
          card_recommendation: {
            offer_id: offer.id,
          },
        )
        raise '?' unless result.success?
        result['model'].tap { |rec| rec.update!(attrs) }
      end

      to_not_expire = [
        # recommended recently:
        create_rec(recommended_at: keep),
        # recommended recently and seen:
        create_rec(recommended_at: keep, seen_at: now),
        # recommended recently, seen, and clicked
        create_rec(recommended_at: keep, seen_at: now, clicked_at: now),
        # recommended before cutoff point, but clicked
        create_rec(recommended_at: lose, seen_at: now, clicked_at: now),
        # recommended before cutoff point, but declined
        create_rec(recommended_at: lose, seen_at: now, declined_at: now, decline_reason: 'X'),
        # recommended before cutoff point, but applied
        create_rec(recommended_at: lose, seen_at: now, applied_at: now),
        # recommended before cutoff point, but pulled:
        create_rec(recommended_at: lose, pulled_at: now),
      ]

      # accounts that were already expired shouldn't have their expired_at date
      # changed:
      already_expired = create_rec(recommended_at: lose, expired_at: 5.days.ago)

      # 5.days.ago has nanosecond precision, but when `already_expired` is
      # reloaded from the DB then its timestamp will be rounded to microsecond
      # precision (on Codeship only), which makes it appear that the timestamp
      # has changed, so the spec will fail on CI. Reload it now so it's already
      # rounded:
      already_expired.reload

      to_expire = [
        # recommended > 15 days ago:
        create_rec(recommended_at: lose),
        # cards that have only been *seen* should still expire:
        create_rec(recommended_at: lose, seen_at: now),
      ]

      expect do
        op.()
        already_expired.reload
      end.not_to change { already_expired.expired_at }

      to_not_expire.each(&:reload)

      expect(to_not_expire.map(&:expired_at).compact).to eq []

      to_expire.each do |rec|
        expect(rec.reload.expired_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end
  end
end
