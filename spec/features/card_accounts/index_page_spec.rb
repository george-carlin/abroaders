require "rails_helper"

describe "as a user viewing my cards" do
  include_context "logged in"

  subject { page }

  let(:me) { account.owner }
  let(:partner) { account.partner }

  before do
    create(:companion, account: account) if has_partner

    @existing_notes = create_list(
      :recommendation_note,
      no_of_existing_notes,
      account: account
    )

    extra_setup
    visit card_accounts_path
  end

  let(:extra_setup) { nil }
  let(:has_partner) { false }
  let(:no_of_existing_notes) { 0 }

  H = "h3"

  let(:pending_recs_notice) { t("card_accounts.index.recs_coming_soon") }

  context "when I have not been recommended any cards" do
    it "tells me that recs are coming" do
      expect(page).to have_content pending_recs_notice
    end

    it "doesn't show recommendation notes" do
      expect(page).to have_no_content "Recommendation Notes"
    end
  end

  context "when I have been recommended some cards" do
    let(:extra_setup) do
      @recs = create_list(:card_recommendation, 2, person: me)
    end

    it "lists them all" do
      within "#owner_card_recommendations" do
        @recs.each do |recommendation|
          rec_on_page = get_card_account_on_page(recommendation)
          expect(rec_on_page).to be_present
          expect(rec_on_page).to have_content recommendation.card.name
          expect(rec_on_page).to have_content recommendation.card.bank_name
        end
      end
    end

    it "doesn't have a header with my name" do
      expect(page).to have_no_selector H, text: "#{me.first_name}'s Cards"
    end

    describe "and i have recommendation notes" do
      let(:no_of_existing_notes) { 2 }
      it "shows most recent recommendation note only" do
        expect(page).to have_content    @existing_notes.last.content
        expect(page).to have_no_content @existing_notes.first.content
      end
    end

    describe "which I haven't seen yet" do
      it "updates the time i saw them" do
        @recs.each do |recommendation|
          recommendation.reload
          expect(recommendation.seen_at).to be_within(2.seconds).of(Time.now)
        end
      end
    end

    describe "which I have already seen" do
      let(:extra_setup) do
        @recs = create_list(:card_recommendation, 2, person: me, seen_at: 1.day.ago)
      end

      it "doesn't change my seen_at time" do
        @recs.each do |recommendation|
          expect(recommendation.seen_at).to be_within(5.seconds).of(1.day.ago)
        end
      end
    end
  end

  context "when I have a partner" do
    let(:has_partner) { true }

    context "and neither of us have been recommended any cards" do
      it "tells me that recs are coming" do
        expect(page).to have_content pending_recs_notice
      end
    end

    it "doesn't have headers with me or my partner's names" do
      expect(page).to have_no_selector H, text: "#{me.first_name}'s Cards"
      expect(page).to have_no_selector H, text: "#{partner.first_name}'s Cards"
    end

    describe "when my partner has card recommendations" do
      let(:extra_setup) do
        @recs = create_list(:card_recommendation, 2, person: partner)
      end

      it "lists them under his name" do
        within "#partner_card_recommendations" do
          @recs.each do |recommendation|
            rec_on_page = get_card_account_on_page(recommendation)
            expect(rec_on_page).to be_present
            expect(rec_on_page).to have_content recommendation.card.name
            expect(rec_on_page).to have_content recommendation.card.bank_name
          end
        end
      end

      it "has headers with me or my partner's names" do
        expect(page).to have_selector H, text: "#{me.first_name}'s Cards"
        expect(page).to have_selector H, text: "#{partner.first_name}'s Cards"
      end
    end

    describe "when I have card recommendations" do
      before { pending }
      it "lists them under my name"

      it "has headers with me or my partner's names" do
        expect(page).to have_selector H, text: "#{me.first_name}'s Cards"
        expect(page).to have_selector H, text: "#{partner.first_name}'s Cards"
      end
    end

    context "when my partner has been recommended new cards" do
      let(:extra_setup) do
        @recs = create_list(:card_recommendation, 2, person: partner)
      end

      it "updates the time i saw them" do
        @recs.each do |recommendation|
          recommendation.reload
          expect(recommendation.seen_at).to be_within(2.seconds).of(Time.now)
        end
      end
    end

    context "when I have have already seen my partner card offers" do
      let(:extra_setup) do
        @recs = create_list(:card_recommendation, 2, person: partner, seen_at: 1.day.ago)
      end

      it "doesn't change my seen_at time" do
        @recs.each do |recommendation|
          expect(recommendation.seen_at).to be_within(5.seconds).of(1.day.ago)
        end
      end
    end
  end

  def get_card_account_on_page(card_account)
    CardAccountOnPage.new(card_account, self)
  end

end
