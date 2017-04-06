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

  example '#unresolved?' do
    req = described_class.new
    expect(req.unresolved?).to be true
    req.resolved_at = Time.zone.now
    expect(req.unresolved?).to be false
  end
end
