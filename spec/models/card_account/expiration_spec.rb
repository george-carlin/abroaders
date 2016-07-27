require "rails_helper"

describe CardAccount::Expiration do
  let(:person) { create(:person) }
  let(:offer)  { create(:offer) }

  example ".expirable" do
    # override FactoryGirl.create so we use the same person/offer by default
    # (this way we don't create a ton of extra DB records)
    def create(factory, *args)
      if factory == :card_rec
        opts = args.extract_options!
        opts.merge!(person: person, offer: offer)
        super(factory, *args, opts)
      else
        super(factory, *args)
      end
    end

    # Recs which aren't expirable:
    applied_rec  = create(:card_rec, :applied)
    clicked_rec  = create(:card_rec, :clicked)
    declined_rec = create(:card_rec, :declined)
    expired_rec  = create(:card_rec, :expired)
    pulled_rec   = create(:card_rec, :pulled)

    new_rec  = create(:card_rec)
    seen_rec = create(:card_rec, :seen)

    result = CardAccount.expirable

    expect(result).to_not include(applied_rec)
    expect(result).to_not include(clicked_rec)
    expect(result).to_not include(declined_rec)
    expect(result).to_not include(expired_rec)
    expect(result).to_not include(pulled_rec)

    expect(result).to include(new_rec)
    expect(result).to include(seen_rec)
  end

  # this spec is dogshit; an extremely low-priority TODO would be to rewrite
  # in the style of the spec for .expirable
  example ".expire_old_recommendations!" do
    lose = 16.days.ago
    keep = 15.days.ago + 1.minute

    to_not_expire = [
      # recommended recently:
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: keep
      ),
      # added in onboarding survey:
      person.card_accounts.from_survey.create!(offer: offer),
      # recommended recently and seen:
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: keep,
        seen_at: Time.now
      ),
      # recommended recently, seen, and clicked
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: keep,
        seen_at: Time.now,
        clicked_at: Time.now
      ),
      # recommended before cutoff point, but clicked
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        clicked_at: Time.now
      ),
      # recommended before cutoff point, but declined
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        declined_at: Time.now,
        decline_reason: "whatever"
      ),
      # recommended before cutoff point, but applied
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        applied_at: Time.now,
      ),
      # recommended before cutoff point, but pulled:
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        pulled_at: Time.now,
      ),
    ]

    # accounts that were already expired shouldn't have their expired_at date
    # changed:
    already_expired = person.card_recommendations.create!(
      offer: offer,
      recommended_at: lose,
      expired_at: 5.days.ago
    )

    # 5.days.ago has nanosecond precision, but when `already_expired` is
    # reloaded from the DB then the timestamp will be rounded to microsecond
    # precision (on Codeship only), which makes it appear that the timestamp
    # has changed, so the spec will fail on CI. Reload it now so it's already
    # rounded:
    already_expired.reload

    to_expire = [
      # recommended > 15 days ago:
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: lose
      ),
      # cards that have only been *seen* should still expire:
      person.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now
      ),
    ]

    expect do
      CardAccount.expire_old_recommendations!
      already_expired.reload
    end.not_to change{already_expired.expired_at}

    expect(to_not_expire.all? { |ca| ca.reload.expired_at.nil? }).to be true

    to_expire.each do |card_account|
      expect(card_account.reload.expired_at).to be_within(5.seconds).of(Time.now)
    end
  end
end
