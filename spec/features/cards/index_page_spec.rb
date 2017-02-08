require "rails_helper"

RSpec.describe 'as a user viewing my cards' do
  subject { page }

  let(:account)   { create(:account, :eligible, :onboarded) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before do
    create(:companion, account: account, eligible: true) if couples
    login_as(account)
  end

  let(:extra_setup) { nil }
  let(:couples) { false }

  let(:visit_page) { visit cards_path }

  H = 'h3'.freeze

  def rec_selector(rec)
    '#' << dom_id(rec)
  end

  example "not recommended any cards yet" do
    visit_page
    expect(page).to have_content t("cards.index.recs_coming_soon")
  end

  example "solo account with recommendations" do
    recs = create_list(:card_recommendation, 2, person: owner)
    visit_page

    # Lists my recs:
    within "#owner_card_recommendations" do
      recs.each do |rec|
        expect(page).to have_selector rec_selector(rec)
        expect(page).to have_content rec.product.name
        expect(page).to have_content rec.product.bank_name
      end
    end

    # doesn't have a header with my name:
    expect(page).to have_no_selector H, text: "#{owner.first_name}'s Cards"
  end

  example 'recommendation notes' do
    account.recommendation_notes.create!(content: 'whatever')
    account.recommendation_notes.create!(content: "new note\n\nhttp://example.com")

    create(:card_recommendation, person: owner)
    owner.update(last_recommendations_at: Time.zone.now)
    visit_page
    # shows most recent recommendation note only:
    expect(page).to have_content    'new note'
    expect(page).to have_no_content 'whatever'
    # formats note properly:
    expect(page).to have_selector 'p', text: /\Anew note\z/
    expect(page).to have_link 'http://example.com', href: 'http://example.com'
  end

  example "marking recs as 'seen'" do
    unseen_rec  = create(:card_recommendation, person: owner)
    seen_rec    = create(:card_recommendation, seen_at: Time.zone.yesterday, person: owner)
    survey_card = create(:card, :survey, person: owner)

    other_persons_rec = create(:card_recommendation, person: create(:person))

    expect do
      visit_page
      seen_rec.reload
    end.not_to change { seen_rec.seen_at }
    expect(unseen_rec.reload.seen_at).to be_within(5.seconds).of(Time.zone.now)
    expect(survey_card.reload.seen_at).to be_nil
    expect(other_persons_rec.reload.seen_at).to be_nil
  end

  specify "no subheadings when neither companion or owner has cards" do
    companion = account.create_companion!(first_name: "Dave")
    visit_page

    expect(page).to have_no_selector H, text: "#{owner.first_name}'s Cards"
    expect(page).to have_no_selector H, text: "#{companion.first_name}'s Cards"
  end

  example "display owner and companion card recommendations" do
    companion = account.create_companion!(first_name: "Dave")
    own_recs = create_list(:card_recommendation, 2, person: owner)
    com_recs = create_list(:card_recommendation, 2, person: companion)
    account.reload
    visit_page

    { owner: own_recs, companion: com_recs }.each do |person_type, recs|
      within "##{person_type}_card_recommendations" do
        recs.each do |rec|
          expect(page).to have_selector rec_selector(rec)
          expect(page).to have_content rec.product.name
          expect(page).to have_content rec.product.bank_name
        end
      end
    end

    # has headers with owner's or companion's names:
    expect(page).to have_selector H, text: "#{owner.first_name}'s Cards"
    expect(page).to have_selector H, text: "#{companion.first_name}'s Cards"
  end

  example "pulled recs" do
    companion = account.create_companion!(first_name: "Dave")
    pulled_recs = [
      create(:card_recommendation, :pulled, person: owner),
      create(:card_recommendation, :pulled, person: companion),
    ]

    visit_page

    pulled_recs.each do |rec|
      expect(page).to have_no_selector rec_selector(rec)
    end
  end
end
