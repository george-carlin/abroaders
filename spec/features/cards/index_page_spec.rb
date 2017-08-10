require "rails_helper"

RSpec.describe 'as a user viewing my cards' do
  subject { page }

  let(:account)   { create_account(:eligible, :onboarded) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before { login_as(account) unless skip_login }

  let(:skip_login) { false }

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
    seen_rec = create_card_recommendation(:seen, person_id: owner.id)
    card = create_card_account(person: owner)
    other_person = create_account.owner
    other_persons_rec = create_card_recommendation(:seen, person_id: other_person.id)

    # reload these recs here or you get a weird error on Codeship because
    # of CS's date precision
    seen_rec.reload
    other_persons_rec.reload

    expect do
      visit_page
      seen_rec.reload
      other_persons_rec.reload
    end.not_to change { [seen_rec.seen_at, other_persons_rec.seen_at] }
    expect(unseen_rec.reload.seen_at).to be_within(5.seconds).of(Time.zone.now)
    expect(card.reload.seen_at).to be_nil
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

  example 'when recommended a product with no currency' do
    product = create(:card_product, currency: nil)
    offer = create_offer(card_product: product)
    create_card_recommendation(offer: offer, person: owner)

    visit_page # bug fix: previously it was crashing
    expect(page).to have_content product.name
  end

  context 'as admin logged in as user' do
    let(:skip_login) { true }

    include_context 'logged in as admin'

    it "doesn't mark recs as seen", :js do
      unseen_rec = create_rec(person_id: owner.id)

      visit admin_person_path(owner)
      click_link "Log in as #{owner.first_name}"
      visit cards_path

      expect(unseen_rec.reload.seen_at).to be_nil
    end
  end
end
