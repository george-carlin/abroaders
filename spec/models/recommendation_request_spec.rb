require 'rails_helper'

RSpec.describe RecommendationRequest do
  let(:account) { create(:account, :onboarded, :eligible) }

  example '#confirm!' do
    run!(described_class::Create, { person_type: 'owner' }, 'account' => account)

    req = account.owner.unconfirmed_recommendation_request

    expect(req).to be_unconfirmed
    req.confirm!
    req.reload
    expect(req).to be_confirmed
    expect(req.confirmed_at).to be_within(2.seconds).of(Time.zone.now)
  end

  example '#status' do
    req = described_class.new
    expect(req.status).to eq 'unconfirmed'
    req.confirmed_at = Time.zone.now
    expect(req.status).to eq 'confirmed'
    req.resolved_at = Time.zone.now
    expect(req.status).to eq 'resolved'
  end

  example '#confirmed?' do
    req = described_class.new
    expect(req.confirmed?).to be false
    req.confirmed_at = Time.zone.now
    expect(req.confirmed?).to be true
    req.resolved_at = Time.zone.now
    expect(req.confirmed?).to be true
  end

  example '#resolved?' do
    req = described_class.new
    expect(req.resolved?).to be false
    req.confirmed_at = Time.zone.now
    expect(req.resolved?).to be false
    req.resolved_at = Time.zone.now
    expect(req.resolved?).to be true
  end

  example '#unresolved?' do
    req = described_class.new
    expect(req.unresolved?).to be true
    req.confirmed_at = Time.zone.now
    expect(req.unresolved?).to be true
    req.resolved_at = Time.zone.now
    expect(req.unresolved?).to be false
  end

  example '#unconfirmed?' do
    req = described_class.new
    expect(req.unconfirmed?).to be true
    req.confirmed_at = Time.zone.now
    expect(req.unconfirmed?).to be false
    req.resolved_at = Time.zone.now
    expect(req.unconfirmed?).to be false
  end
end
