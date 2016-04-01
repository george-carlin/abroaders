require "rails_helper"

context "as an onboarded user" do
  subject { page }

  before do
    @account = create(
      :account,
      email: email,
      time_zone: time_zone,
      shares_expenses: shares_expenses,
    )
    @account.build_main_passenger(
      first_name:   "James",
      middle_names: "Earl",
      last_name:    "Jones",
      phone_number: "(555) 000 1234",
      text_message: true,
      whatsapp:     true,
      imessage:     true,
      citizenship: :us_citizen,
      willing_to_apply: true,
    )
    create(:spending_info, passenger: @account.main_passenger)
    if has_companion
      @account.build_companion(
        first_name:   "Luke",
        middle_names: "George",
        last_name:    "Skywalker",
        phone_number: "(098) 555 5432",
        citizenship: :us_permanent_resident,
        willing_to_apply: false
      )
      create(:spending_info, passenger: @account.companion)
    end
    @account.onboarding_stage = "onboarded"
    @account.save!
    login_as @account, scope: :account
  end

  let(:account) { @account }
  let(:email) { "thedude@lebowski.com" }
  let(:time_zone) { "London" }
  let(:shares_expenses) { false }
  let(:has_companion)   { true }

  def within_main_passenger
    within("##{dom_id(account.main_passenger)}") { yield }
  end

  def within_companion
    within("##{dom_id(account.companion)}") { yield }
  end

  describe "visiting my account dashboard page (currently the root path)" do
    before { visit root_path }

    it "shows me the basic information about my account" do
      within ".container" do
        is_expected.to have_content email
        is_expected.to have_content ActiveSupport::TimeZone.new(time_zone).to_s
      end
    end

    it "shows me information about the main passenger" do
      within_main_passenger do
        expect(page).to have_selector "h2", text: "James Earl Jones"
        expect(page).to have_content "(555) 000 1234"
        expect(page).to have_selector \
          ".passenger-phone-can-receive-icons .fa-comment" # text messages
        expect(page).to have_selector \
          ".passenger-phone-can-receive-icons .fa-whatsapp" # WhatsApp
        expect(page).to have_selector \
          ".passenger-phone-can-receive-icons .fa-wechat" # iMessage
        expect(page).to have_content "U.S. Citizen"
      end
    end

    # This is implemented, but needs a test:
    it "shows me the main passenger's spending info"

    context "when I don't have a companion" do
      let(:has_companion) { false }

      it "doesn't say anything about 'willing to apply for cards'" do
        expect(page).not_to have_content "willing to apply"
      end
    end

    context "when I have a companion" do
      let(:has_companion) { true }

      it "shows me information about my companion" do
        within_companion do
          expect(page).to have_selector "h2", text: "Luke George Skywalker"
          expect(page).to have_content "(098) 555 5432"
          expect(page).not_to have_selector \
            ".passenger-phone-can-receive-icons .fa-comment" # text messages
          expect(page).not_to have_selector \
            ".passenger-phone-can-receive-icons .fa-whatsapp" # WhatsApp
          expect(page).not_to have_selector \
            ".passenger-phone-can-receive-icons .fa-wechat" # iMessage
          expect(page).to have_content "U.S. Permanent Resident"
        end
      end

      # This is implemented, but needs a test:
      it "shows me the companion's spending info"

      it "says whether or not we are willing to apply for cards" do
        within_main_passenger do
          expect(page).to have_content \
            "You have indicated that James is willing to apply for cards"
        end

        within_companion do
          expect(page).to have_content \
            "You have indicated that Luke is not willing to apply for cards"
        end
      end
    end
  end
end
