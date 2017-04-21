require 'rails_helper'

RSpec.describe CardRecommendation::Operation::UpdateStatus::Applied do
  let(:op) { described_class }

  let(:account) { create(:account, :onboarded) }
  let(:person) { account.owner }

  let(:rec) { create_card_recommendation(person_id: person.id) }

  example 'success' do
    result = op.({ id: rec.id }, 'account' => account)
    expect(result.success?).to be true
    expect(result['model']).to eq rec
    rec.reload
    expect(rec.applied_on).to eq Date.today
  end

  example 'failure - not my rec' do # fail noisily
    other_account = create(:account, :onboarded)
    expect do
      op.({ id: rec.id }, 'account' => other_account)
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(rec.reload.applied_on).to be nil
  end

  # the below failures may happen if e.g. they have the page open in two tabs;
  # they need to be handled gracefully:

  example 'failure - rec already applied for' do
    # apply for real:
    result = op.({ id: rec.id }, 'account' => account)
    raise unless result.success?

    # try applying again:
    result = op.({ id: rec.id }, 'account' => account)
    expect(result.success?).to be false
    expect(result['error']).to eq t("cards.invalid_status_error")
  end

  example 'failure - rec expired' do
    rec.update!(expired_at: Time.zone.now)

    result = op.({ id: rec.id }, 'account' => account)
    expect(result.success?).to be false
    expect(result['error']).to eq t("cards.invalid_status_error")
  end

  example 'failure - rec declined' do
    run!(
      CardRecommendation::Operation::Decline,
      { id: rec.id, card: { decline_reason: 'x' } },
      'account' => account,
    )

    result = op.({ id: rec.id }, 'account' => account)
    expect(result.success?).to be false
    expect(result['error']).to eq t("cards.invalid_status_error")
  end
end
