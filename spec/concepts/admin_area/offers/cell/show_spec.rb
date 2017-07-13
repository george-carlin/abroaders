require 'cells_helper'

RSpec.describe AdminArea::Offers::Cell::Show do
  let(:offer) { create_offer }

  def have_dead_icon
    have_selector '.fa.fa-times'
  end

  def have_active_recs_icon
    have_selector '.fa.fa-exclamation-triangle'
  end

  example 'offer is live' do
    rendered = cell(offer.reload).()
    expect(rendered).not_to have_dead_icon
    expect(rendered).not_to have_active_recs_icon
  end

  example 'offer is dead' do
    kill_offer(offer)
    rendered = cell(offer.reload).()
    expect(rendered).to have_dead_icon
    expect(rendered).not_to have_active_recs_icon
  end

  example 'offer is dead and has active recs' do
    create_rec(offer: offer)
    kill_offer(offer)
    rendered = cell(offer.reload).()
    expect(rendered).to have_dead_icon
    expect(rendered).to have_active_recs_icon
  end
end
