require "rails_helper"

describe "account dashboard" do
  subject { page }

  let(:email) { "thedude@lebowski.com" }
  let!(:account) { create(:account, email: email) }
  let!(:me) { account.people.create!(first_name: "Adam") }

  before do
    extra_setup
    login_as_account(account.reload)
    visit root_path
  end

  let(:extra_setup) { nil }

  # if two_applicants
  #   @him = account.people.create!(first_name: "Bob")
  #   create(:spending_info, person: @him)
  # end

  def within_my_info
    within("##{dom_id(me)}") { yield }
  end

  def within_companion
    within("##{dom_id(account.companion)}") { yield }
  end

  context "when I have no travel plans" do
    it { is_expected.to have_content "You have no upcoming travel plans" }
    it { is_expected.to have_link "Add one", href: new_travel_plan_path }
  end

  context "when I have added travel plans" do
    let(:extra_setup) do
      @travel_plans = create_list(:travel_plan, 2, account: account)
    end

    it { is_expected.to have_link "Add new", href: new_travel_plan_path }

    it "displays them" do
      @travel_plans.each do |plan|
        expect(page).to have_selector "##{dom_id(plan)}"
      end
    end
  end

  context "when I have not added my spending info" do
    it "tells me to add it before I can be recommended cards" do
      expect(page).to have_content \
        "You have not added this person's financial details"
      expect(page).to have_link "Add financial information",
          href: new_person_spending_info_path(me)
    end
  end

  context "when I have added my spending info" do
    let(:extra_setup) do
      me.create_spending_info!(
        credit_score: 456,
        will_apply_for_loan: true,
        has_business: "without_ein",
        business_spending_usd: 1234,
        citizenship: "us_permanent_resident",
      )
    end

    it "displays it" do
      within_my_info do
        expect(page).to have_content "Credit score: 456"
        expect(page).to have_content "Business spending: $1,234.00 (Does not have EIN)"
        expect(page).to have_content "Will apply for loan in next 6 months: Yes"
      end
    end

    it { pending; is_expected.to have_link "Edit", href: edit_person_spending_info_path(me) }
  end

  context "when I have not added any cards" do
    it "tells me to add them before I can be recommended cards" do
      expect(page).to have_content \
        "Before we can recommend any credit cards to this person, "\
        "we need to know which cards they already have."
      expect(page).to have_link "Add existing cards",
          href: survey_person_card_accounts_path(me)
    end
  end

  context "when I have added my cards" do
    let(:extra_setup) do
      me.update_attributes!(onboarded_cards: true)
      create_list(:card_account, 2, person: me)
    end

    it "displays info about them" do
      # TODO this is just a placeholder for now; should show more
      expect(page).to have_content "2 cards on file"
    end
  end

  context "when I have not added any balances" do
    it "tells me to add them before I can be recommended cards" do
      expect(page).to have_content \
        "You have not added any frequent flyer balances"
      expect(page).to have_link "Add balances",
          href: survey_person_balances_path(me)
    end
  end

  context "when I have completed the balances survey" do
    let(:onboard!) { me.update_attributes!(onboarded_balances: true) }
    let(:extra_setup) { onboard! }

    context "but said I have no balances" do
      it { is_expected.to have_content "This person has no existing frequent flyer balances" }
    end

    context "and added some balances" do
      let!(:currencies) { create_list(:currency, 2) }
      let(:extra_setup) do
        onboard!
        create(:balance, person: me, currency: currencies[0], value: 12_345)
        create(:balance, person: me, currency: currencies[1], value: 543_543)
      end

      it "displays info about them" do
        expect(page).to have_content "#{currencies[0].name}: 12,345"
        expect(page).to have_content "#{currencies[1].name}: 543,543"
      end
    end
  end
end
