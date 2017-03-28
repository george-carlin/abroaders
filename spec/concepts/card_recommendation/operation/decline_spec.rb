require 'rails_helper'

RSpec.describe CardRecommendation::Operation::Decline do
  let(:op) { described_class }

  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:offer)   { create_offer }

  let(:rec) do
    AdminArea::CardRecommendations::Operation::Create.(
      card_recommendation: { offer_id: offer.id }, person_id: person.id,
    )['model']
  end

  example 'success' do
    result = op.(
      { id: rec.id, card: { decline_reason: ' X ' } },
      'account' => account,
    )
    expect(result.success?).to be true
    # FIXME declined_at should be a datetime, not a date
    # expect(rec.reload.declined_at).to be_within(5.seconds).of Time.now
    rec.reload
    expect(rec.declined_at).to eq Date.today
    expect(rec.decline_reason).to eq 'X' # it strips whitespace

    expect(rec).to eq result['model']
  end

  # the below failures may happen if e.g. they have the page open in two tabs;
  # they need to be handled gracefully:

  example 'failure - rec already declined' do
    # decline it validly:
    result = op.(
      { id: rec.id, card: { decline_reason: 'X' } },
      'account' => account,
    )
    expect(result.success?).to be true
    # and try again:
    result = op.(
      { id: rec.id, card: { decline_reason: 'X' } },
      'account' => account,
    )
    expect(result.success?).to be false
    expect(result['error']).to eq described_class::COULDNT_DECLINE
  end

  example 'failure - rec already applied for' do
    # TODO replace with an op once we have one:
    rec.update!(applied_on: Time.now)
    result = op.(
      { id: rec.id, card: { decline_reason: 'X' } },
      'account' => account,
    )
    expect(result.success?).to be false
    expect(rec.reload.declined_at).to be nil
    expect(result['error']).to eq described_class::COULDNT_DECLINE
  end

  example 'failure - rec not found' do # fail noisily:
    other_account = create(:account, :onboarded)
    expect do
      op.({ id: rec.id }, 'account' => other_account)
    end.to raise_error ActiveRecord::RecordNotFound
  end

  example 'failure - decline reason blank' do # fail noisily:
    expect do
      op.({ id: rec.id, card: { decline_reason: ' ' } }, 'account' => account)
    end.to raise_error RuntimeError
  end
end
