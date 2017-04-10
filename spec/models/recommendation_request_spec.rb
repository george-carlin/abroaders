require 'rails_helper'

RSpec.describe RecommendationRequest do
  let(:account) { create(:account, :onboarded, :eligible) }

  example '#status' do
    req = described_class.new
    expect(req.status).to eq 'unresolved'
    req.resolved_at = Time.zone.now
    expect(req.status).to eq 'resolved'
  end

  example '#resolved?' do
    req = described_class.new
    expect(req.resolved?).to be false
    req.resolved_at = Time.zone.now
    expect(req.resolved?).to be true
  end

  example '#resolve!' do
    account = create(:account, :eligible)
    create_rec_request('owner', account)
    req = account.unresolved_recommendation_requests.last
    result = req.resolve!
    expect(req).to be_resolved
    expect(req.resolved_at).to be_within(2.seconds).of(Time.zone.now)
    expect(req.resolved_at).to eq result
  end

  example '#resolve! when req is already resolved' do
    account = create(:account, :eligible)
    create_rec_request('owner', account)
    req = account.unresolved_recommendation_requests.last
    req.resolve! # resolve once
    expect do # and try to resolve it again:
      req.resolve!
    end.to raise_error(RecommendationRequest::AlreadyResolvedError)
  end

  example '#unresolved?' do
    req = described_class.new
    expect(req.unresolved?).to be true
    req.resolved_at = Time.zone.now
    expect(req.unresolved?).to be false
  end
end
