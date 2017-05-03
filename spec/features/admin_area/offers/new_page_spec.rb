require 'rails_helper'

RSpec.describe 'admin area - new offer page' do
  include_context 'logged in as admin'
  subject { page }

  let(:bank) { Bank.all.first }
  before do
    @product = create(
      :card_product,
      name: 'Sapphire Preferred',
      network: 'visa',
      annual_fee_cents: 150_000,
      business: true,
      bank: bank,
    )

    visit new_admin_card_product_offer_path(@product)
  end

  let(:submit) { click_button t("admin.offers.submit") }

  it { is_expected.to have_title full_title("New Offer") }

  example 'page layout' do
    # it "displays information about the product" do
    expect(page).to have_content bank.name
    expect(page).to have_content "Sapphire Preferred"
    expect(page).to have_content "Visa"
    expect(page).to have_content "$1,500"
    expect(page).to have_content "business"

    # it "has fields for an offer" do
    expect(page).to have_field :offer_condition
    expect(page).to have_field :offer_points_awarded
    expect(page).to have_field :offer_spend
    expect(page).to have_field :offer_cost
    expect(page).to have_field :offer_days
    expect(page).to have_field :offer_partner
    expect(page).to have_field :offer_link
    expect(page).to have_field :offer_notes

    # the 'condition' dropdown has 'on minimum spend' selected by default
    selected_opt = find("#offer_condition option[selected]")
    expect(selected_opt.value).to eq "on_minimum_spend"
  end

  let(:new_offer) { Offer.last }

  describe "selecting 'on approval' condition'", :js do
    before { select 'Approval', from: :offer_condition }

    example 'hides/shows inputs' do
      expect(page).to have_no_field :offer_spend
      expect(page).to have_no_field :offer_days
      select 'Minimum spend', from: :offer_condition
      expect(page).to have_field :offer_spend
      expect(page).to have_field :offer_days
    end

    example 'and submitting the form with valid info' do
      fill_in :offer_points_awarded, with: 40_000
      fill_in :offer_link, with: "http://something.com"
      expect { submit }.to change { Offer.count }.by 1
      expect(new_offer.condition).to eq "on_approval"
      expect(new_offer.product).to eq @product
      expect(new_offer.points_awarded).to eq 40_000
      expect(new_offer.link).to eq "http://something.com"
      expect(new_offer.spend).to be_nil
      expect(new_offer.days).to be_nil
    end

    example "and submitting the form with invalid info" do
      submit
      # it "shows the form again with the correct fields hidden/shown" do
      expect(page).to have_field :offer_condition
      expect(page).to have_field :offer_points_awarded
      expect(page).to have_no_field :offer_spend
      expect(page).to have_field :offer_cost
      expect(page).to have_no_field :offer_days
      expect(page).to have_field :offer_link
      expect(page).to have_field :offer_notes
    end
  end

  describe "selecting 'on first purchase' condition'", :js do
    before { select 'First purchase', from: :offer_condition }

    it 'hides/shows inputs' do
      expect(page).to have_no_field :offer_spend
      select 'Minimum spend', from: :offer_condition
      expect(page).to have_field :offer_spend
    end

    example 'and submitting the form with valid info' do
      fill_in :offer_points_awarded, with: 40_000
      fill_in :offer_link, with: 'http://something.com'
      fill_in :offer_days, with: 120
      expect { submit }.to change { Offer.count }.by 1

      expect(new_offer.condition).to eq 'on_first_purchase'
      expect(new_offer.product).to eq @product
      expect(new_offer.days).to eq 120
      expect(new_offer.points_awarded).to eq 40_000
      expect(new_offer.link).to eq 'http://something.com'
      expect(new_offer.spend).to be_nil
    end

    example 'and submitting the form with invalid info' do
      submit
      expect(page).to have_field :offer_condition
      expect(page).to have_field :offer_partner
      expect(page).to have_field :offer_points_awarded
      expect(page).to have_no_field :offer_spend
      expect(page).to have_field :offer_cost
      expect(page).to have_field :offer_days
      expect(page).to have_field :offer_link
      expect(page).to have_field :offer_notes
    end
  end

  describe 'selecting "CardRatings.com" partner', :js do
    example "and submitting the form with valid info" do
      select 'CardRatings.com', from: :offer_partner
      fill_in :offer_points_awarded, with: 40_000
      fill_in :offer_link, with: "http://something.com"
      expect { submit }.to change { ::Offer.count }.by 1
      expect(new_offer.partner).to eq "card_ratings"
    end
  end

  example 'submitting the form with valid information' do
    select 'AwardWallet', from: :offer_partner
    fill_in :offer_points_awarded, with: 40_000
    fill_in :offer_spend, with: 5000
    fill_in :offer_link, with: 'http://something.com'

    expect { submit }.to change { Offer.count }.by(1)
    expect(new_offer.condition).to eq 'on_minimum_spend'
    expect(new_offer.partner).to eq 'award_wallet'
    expect(new_offer.product).to eq @product
    expect(new_offer.points_awarded).to eq 40_000
    expect(new_offer.spend).to eq 5_000
    expect(new_offer.link).to eq 'http://something.com'
  end

  example 'submitting the form with invalid information' do
    submit
    # it 'shows the form again with an error message' do
    expect(page).to have_selector 'form#new_offer'
    expect(page).to have_error_message
  end
end # new page
