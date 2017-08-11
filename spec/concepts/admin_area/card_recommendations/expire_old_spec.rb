require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::ExpireOld do
  let(:admin) { create_admin }
  let(:person) { create_account.owner }
  let(:offer)  { create_offer }
  let(:now) { Time.zone.now }

  let(:op) { described_class }

  let(:max) { op['expire_after_no_of_days'] }

  example '.call' do
    lose = (max + 1).days.ago
    keep = max.days.ago + 1.minute

    # use the 'real' operation to create the rec, then update the
    # rest of the attrs manually:
    def create_rec(attrs = {})
      create_card_recommendation(offer_id: offer.id, person_id: person.id).tap do |rec|
        rec.update!(attrs)
      end
    end

    # in these variable names, 'new' means they were recommended more
    # recently that the cutoff point and 'old' means that they're older

    # recs which shouldn't have their expiry date set:
    new      = create_rec(recommended_at: keep)
    seen     = create_rec(recommended_at: keep, seen_at: now)
    clicked  = create_rec(recommended_at: keep, seen_at: now, clicked_at: now)
    old_and_clicked  = create_rec(recommended_at: lose, seen_at: now, clicked_at: now)
    old_and_declined = create_rec(recommended_at: lose, seen_at: now, declined_at: now, decline_reason: 'X')
    old_and_applied = create_rec(recommended_at: lose, seen_at: now, applied_on: now)

    # accounts that were already expired shouldn't have their expired_at date
    # changed:
    already_expired = create_rec(recommended_at: lose, expired_at: 5.days.ago)

    # 5.days.ago has nanosecond precision, but when `already_expired` is
    # reloaded from the DB then its timestamp will be rounded to microsecond
    # precision (on Codeship only), which makes it appear that the timestamp
    # has changed, so the spec will fail on CI. Reload it now so it's already
    # rounded:
    already_expired.reload

    # to expire:
    # recommended > max days ago:
    old = create_rec(recommended_at: lose)
    # cards that have only been *seen* should still expire:
    old_and_seen = create_rec(recommended_at: lose, seen_at: now)

    expect do
      op.({}, 'current_admin' => admin)
      already_expired.reload
    end.not_to change { already_expired.expired_at }

    expect(new.reload.expired_at).to be nil
    expect(seen.reload.expired_at).to be nil
    expect(clicked.reload.expired_at).to be nil
    expect(old_and_clicked.reload.expired_at).to be nil
    expect(old_and_declined.reload.expired_at).to be nil
    expect(old_and_applied.reload.expired_at).to be nil

    expect(old.reload.expired_at).to be_within(5.seconds).of(Time.zone.now)
    # cards that have only been *seen* should still expire:
    expect(old_and_seen.reload.expired_at).to be_within(5.seconds).of(Time.zone.now)
  end
end
