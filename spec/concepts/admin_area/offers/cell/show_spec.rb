require 'cells_helper'

RSpec.describe AdminArea::Offers::Cell::Show do
  let(:offer) { create_offer }

  def have_dead_icon
    have_selector '.fa.fa-times'
  end

  def have_active_recs_icon
    have_selector '.fa.fa-exclamation-triangle'
  end

  example 'links' do
    rendered = cell(offer.reload).()
    expect(rendered).to have_link 'Edit offer', href: edit_admin_offer_path(offer)
    expect(rendered).to have_link(
      'New offer for product',
      href: new_admin_card_product_offer_path(offer.card_product),
    )
    # TODO add link to duplicate offer
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
