require 'rails_helper'

require 'admin_area/offer/cell/last_reviewed_at'

RSpec.describe AdminArea::Offer::Cell::LastReviewedAt do
  let(:cell) { described_class }

  let(:offer_class) { Struct.new(:last_reviewed_at) }

  example '#show' do
    rendered = cell.(offer_class.new(nil)).()
    expect(rendered).to eq 'never'
    rendered = cell.(offer_class.new(Date.new(2016, 0o1, 0o2))).()
    expect(rendered).to eq '01/02/2016'
  end
end
