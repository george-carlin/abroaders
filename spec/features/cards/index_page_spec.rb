require "rails_helper"

RSpec.describe 'as a user viewing my cards' do
  subject { page }

  let(:account)   { create(:account, :eligible, :onboarded) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before do
    create_companion(account: account, eligible: true) if couples
    login_as(account)
  end

  let(:extra_setup) { nil }
  let(:couples) { false }

  let(:visit_page) { visit cards_path }

  H = 'h3'.freeze

  example "not recommended any cards yet" do
    visit_page
    expect(page).to have_no_content 'My recommendations'
  end

  example "solo account with recommendations" do
    recs = Array.new(2) { create_card_recommendation(person_id: owner.id) }
    visit_page

    # Lists my recs:
    within "#owner_card_recommendations" do
      recs.each do |rec|
        expect(page).to have_selector "#card_recommendation_#{rec.id}"
        expect(page).to have_content rec.card_product.name
        expect(page).to have_content rec.card_product.bank_name
      end
    end

    # doesn't have a header with my name:
    expect(page).to have_no_selector H, text: "#{owner.first_name}'s Recommendations"
  end

  example 'recommendation notes' do
    account.recommendation_notes.create!(content: 'whatever')
    account.recommendation_notes.create!(content: "new note\n\nhttp://example.com")

    create_card_recommendation(person_id: owner.id)
    visit_page
    # shows most recent recommendation note only:
    expect(page).to have_content    'new note'
    expect(page).to have_no_content 'whatever'
    # formats note properly:
    expect(page).to have_selector 'p', text: /\Anew note\z/
    expect(page).to have_link 'http://example.com', href: 'http://example.com'
  end

  example "marking recs as 'seen'" do
    unseen_rec = create_card_recommendation(person_id: owner.id)
    seen_rec   = create_card_recommendation(:seen, person_id: owner.id)
    card       = create_card_account(person: owner)

    seen_rec   =
      other_persons_rec = create_card_recommendation(:seen, person_id: create_person.id)

    expect do
      visit_page
      seen_rec.reload
    end.not_to change { seen_rec.seen_at }
    expect(unseen_rec.reload.seen_at).to be_within(5.seconds).of(Time.zone.now)
    expect(card.reload.seen_at).to be_nil
    expect(other_persons_rec.reload.seen_at).to be_nil
  end

  specify "no subheadings when neither companion or owner has cards" do
    companion = account.create_companion!(first_name: "Dave")
    visit_page

    expect(page).to have_no_selector H, text: "#{owner.first_name}'s Recommendations"
    expect(page).to have_no_selector H, text: "#{companion.first_name}'s Recommendations"
  end

  example "display owner and companion card recommendations" do
    companion = account.create_companion!(first_name: "Dave")
    own_recs = Array.new(2) { create_card_recommendation(person_id: owner.id) }
    com_recs = Array.new(2) { create_card_recommendation(person_id: companion.id) }
    account.reload
    visit_page

    { owner: own_recs, companion: com_recs }.each do |person_type, recs|
      within "##{person_type}_card_recommendations" do
        recs.each do |rec|
          expect(page).to have_selector "#card_recommendation_#{rec.id}"
          expect(page).to have_content rec.card_product.name
          expect(page).to have_content rec.card_product.bank_name
        end
      end
    end

    # has headers with owner's or companion's names:
    expect(page).to have_selector H, text: "#{owner.first_name}'s Recommendations"
    expect(page).to have_selector H, text: "#{companion.first_name}'s Recommendations"
  end
end
