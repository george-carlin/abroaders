require "rails_helper"

describe CardAccount::Expiration do
  example ".expire_old_recommendations!" do
    account_0 = create(:account)
    # account_1 = create(:account, :with_companion)

    lose = 16.days.ago
    keep = 15.days.ago + 1.minute

    offer = create(:offer)

    owner_0 = account_0.owner

    to_not_expire = [
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: keep
      ),
      owner_0.card_accounts.from_survey.create!(offer: offer),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: keep,
        seen_at: Time.now
      ),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: keep,
        seen_at: Time.now,
        clicked_at: Time.now
      ),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        clicked_at: Time.now
      ),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        declined_at: Time.now,
        decline_reason: "whatever"
      ),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        declined_at: Time.now,
        decline_reason: "whatever"
      ),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        declined_at: Time.now,
        decline_reason: "whatever"
      ),
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: lose,
        seen_at: Time.now,
        applied_at: Time.now,
      ),
    ]

    already_expired = owner_0.card_recommendations.create!(
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
      owner_0.card_recommendations.create!(
        offer: offer,
        recommended_at: lose
      ),
      owner_0.card_recommendations.create!(
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
