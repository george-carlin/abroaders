require "rails_helper"

describe "as a user viewing my cards" do
  include_context "logged in"

  subject { page }

  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before do
    create(:companion, account: account) if has_companion

    @existing_notes = create_list(
      :recommendation_note,
      no_of_existing_notes,
      account: account
    )
  end

  let(:extra_setup) { nil }
  let(:has_companion) { false }
  let(:no_of_existing_notes) { 0 }

  let(:visit_page) { visit card_accounts_path }

  H = "h3"

  example "not recommended any cards yet" do
    visit_page
    expect(page).to have_content t("card_accounts.index.recs_coming_soon")
  end

  example "solo account with recommendations" do
    recs = create_list(:card_recommendation, 2, person: owner)
    visit_page

    # Lists my recs:
    within "#owner_card_recommendations" do
      recs.each do |rec|
        rec_on_page = CardAccountOnPage.new(rec, self)
        expect(rec_on_page).to be_present
        expect(rec_on_page).to have_content rec.card.name
        expect(rec_on_page).to have_content rec.card.bank_name
      end
    end

    # doesn't have a header with my name:
    expect(page).to have_no_selector H, text: "#{owner.first_name}'s Cards"
  end

  example "recommendation notes" do
    existing_notes = create_list(:recommendation_note, 2, account: account)
    visit_page
    # shows most recent recommendation note only:
    expect(page).to have_content    existing_notes.last.content
    expect(page).to have_no_content existing_notes.first.content
  end

  example "marking recs as 'seen'" do
    unseen_rec  = create(:card_recommendation, person: owner)
    seen_rec    = create(:card_recommendation, seen_at: Date.yesterday, person: owner)
    survey_card = create(:card_account, :survey, person: owner)

    other_persons_rec = create(:card_recommendation, person: create(:person))

    expect do
      visit_page
      seen_rec.reload
    end.not_to change{seen_rec.seen_at}
    expect(unseen_rec.reload.seen_at).to be_within(5.seconds).of(Time.now)
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

    {owner: own_recs, companion: com_recs}.each do |person_type, recs|
      within "##{person_type}_card_recommendations" do
        recs.each do |rec|
          rec_on_page = CardAccountOnPage.new(rec, self)
          expect(rec_on_page).to be_present
          expect(rec_on_page).to have_content rec.card.name
          expect(rec_on_page).to have_content rec.card.bank_name
        end
      end
    end

    # has headers with me or my companion's names:
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
      rec_on_page = CardAccountOnPage.new(rec, self)
      expect(rec_on_page).to be_absent
    end
  end

end
