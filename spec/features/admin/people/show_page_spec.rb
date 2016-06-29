require "rails_helper"

describe "admin section - person page", :manual_clean do
  include_context "logged in as admin"
  subject { page }

  let(:aw_email) { "totallyawesomedude@example.com" }

  before(:all) do
    @currencies = create_list(:currency, 4)
    @chase   = Bank.find_by(name: "Chase")
    @us_bank = Bank.find_by(name: "US Bank")

    def create_card(bp, bank, currency)
      create(:card, bp, bank_id: bank.id, currency: currency)
    end

    @cards = [
      @chase_b = create_card(:business, @chase,   @currencies[0]),
      @chase_p = create_card(:personal, @chase,   @currencies[1]),
      @usb_b   = create_card(:business, @us_bank, @currencies[2]),
      @usb_p   = create_card(:personal, @us_bank, @currencies[3]),
    ]

    @offers = [
      create(:offer, card: @chase_b),
      create(:offer, card: @chase_b),
      create(:offer, card: @chase_p),
      create(:offer, card: @usb_b),
      create(:offer, card: @usb_p)
    ]
    @dead_offer = create(:dead_offer, card: @chase_b)
  end

  before do
    @person = create(
      :person,
      :eligible,
      onboarded_cards: true,
      onboarded_balances: true,
      award_wallet_email: aw_email,
    )
    if has_spending?
      @person.create_spending_info!(
        credit_score: 678,
        has_business: :with_ein,
        business_spending_usd: 1500
      )
    end
    @account = @person.account.reload

    create_list(:recommendation_note, no_of_existing_notes, account: account)

    extra_setup
    visit admin_person_path(@person)
  end

  let(:extra_setup) { nil }
  let(:recommend_link_text) { "Recommend a card" }
  let(:account) { @account }
  let(:person)  { @person }
  let(:name)    { @person.first_name }
  let(:chase)   { @chase }
  let(:us_bank) { @us_bank }

  let(:no_of_existing_notes) { 0 }
  let(:dead_offer) { AdminArea::RecommendableOfferOnPage.new(@dead_offer, self) }

  let(:has_spending?) { false }

  it { is_expected.to have_title full_title(@person.first_name) }

  it "shows the date on which the account was created" do
    is_expected.to have_content @account.created_at.strftime("%D")
  end

  it "has the person's name as the page header" do
    is_expected.to have_selector "h1", text: name
  end

  it "displays the award wallet email" do
    is_expected.to have_content "AwardWallet email: #{aw_email}"
  end

  it "says whether this is the main or companion passenger"

  context "when the person hasn't added their spending info" do
    it "says so" do
      is_expected.to have_content "User has not added their spending info"
    end
  end

  context "when the person" do
    context "has added their spending info" do
      let(:has_spending?) { true }
      it "displays it" do
        is_expected.to have_content "Credit score: 678"
        is_expected.to have_content "Will apply for loan in next 6 months: No"
        is_expected.to have_content "Business spending: $1,500.00"
        is_expected.to have_content "(Has EIN)"
      end
    end

    context "has no travel plans" do
      it { is_expected.to have_content "User has no upcoming travel plans" }
    end

    context "has added travel plans" do
      let(:extra_setup) do
        @eu  = create(:region,  name: "Europe")
        @uk  = create(:country, name: "UK",       parent: @eu)
        @lhr = create(:airport, name: "Heathrow", parent: @uk)

        @as  = create(:region,  name: "Asia")
        @vn  = create(:country, name: "Vietnam", parent: @as)
        @sgn = create(:airport, name: "HCMC",    parent: @vn)

        @na  = create(:region,  name: "North America")
        @us  = create(:country, name: "United States", parent: @na)
        @jfk = create(:airport, name: "JFK",           parent: @us)

        @tp_0 = create(
          :travel_plan, :single, account: @account,
          flights: [Flight.new(from: @jfk, to: @lhr)]
        )
        @tp_1 = create(
          :travel_plan, :return, account: @account,
          flights: [Flight.new(from: @na, to: @as)]
        )
        @tp_2 = create(
          :travel_plan, :multi, account: @account,
          flights: [
            Flight.new(from: @jfk, to: @eu, position: 0),
            Flight.new(from: @eu,  to: @vn, position: 1),
            Flight.new(from: @sgn, to: @jfk, position: 2)
          ]
        )
      end

      it "displays information about them" do
        is_expected.to have_no_content "User has no upcoming travel plans"

        # When the destination is a region, just display the region name.
        # When the destination is anything other than a region, display the
        # destination name, and the region name, skipping any intermediary
        # steps. E.g. if the destination is Heathrow, display "Heathrow
        # (Europe)", and don't bother displaying the intermediary
        # destinations like London, England, UK, etc.

        within ".account_travel_plans" do
          is_expected.to have_selector "##{dom_id(@tp_0)}"
          within "##{dom_id(@tp_0)}" do
            is_expected.to have_content "Single"
            is_expected.to have_selector "##{dom_id(@tp_0.flights[0])}"
            within "##{dom_id(@tp_0.flights[0])}" do
              is_expected.to have_content "JFK (North America)"
              is_expected.to have_content "Heathrow (Europe)"
            end
          end

          is_expected.to have_selector "##{dom_id(@tp_1)}"
          within "##{dom_id(@tp_1)}" do
            is_expected.to have_content "Return"
            is_expected.to have_selector "##{dom_id(@tp_1.flights[0])}"
            within "##{dom_id(@tp_1.flights[0])}" do
              is_expected.to have_content "North America"
              is_expected.to have_content "Asia"
            end
          end

          is_expected.to have_selector "##{dom_id(@tp_2)}"
          within "##{dom_id(@tp_2)}" do
            is_expected.to have_content "Multi"
            is_expected.to have_selector "##{dom_id(@tp_2.flights[0])}"
            is_expected.to have_selector "##{dom_id(@tp_2.flights[1])}"
            is_expected.to have_selector "##{dom_id(@tp_2.flights[2])}"

            within "##{dom_id(@tp_2.flights[0])}" do
              is_expected.to have_content "JFK (North America)"
              is_expected.to have_content "Europe"
            end
            within "##{dom_id(@tp_2.flights[1])}" do
              is_expected.to have_content "Europe"
              is_expected.to have_content "Vietnam (Asia)"
            end
            within "##{dom_id(@tp_2.flights[2])}" do
              is_expected.to have_content "HCMC (Asia)"
              is_expected.to have_content "JFK (North America)"
            end
          end
        end
      end
    end

    context "has no existing points balances" do
      let(:no_balances) { t("admin.people.card_recommendations.no_balances") }
      it { is_expected.to have_content no_balances }
    end

    context "has existing points balances" do
      let(:extra_setup) do
        Balance.create!(
          person: @person, currency: @currencies[0], value:  5000
        )
        Balance.create!(
          person: @person, currency: @currencies[2], value: 10000
        )
      end

      it "lists their balances" do
        is_expected.to have_selector "##{dom_id(@currencies[0])} .balance",
                                      text: "5,000"
        is_expected.to have_selector "##{dom_id(@currencies[2])} .balance",
                                      text: "10,000"

        is_expected.to have_no_selector "##{dom_id(@currencies[1])}_balance"
        is_expected.to have_no_selector "##{dom_id(@currencies[3])}_balance"
      end
    end

    context "has existing cards" do
      let(:jan) { Date.parse("2015-01-01") }
      let(:mar) { Date.parse("2015-03-01") }
      let(:oct) { Date.parse("2015-10-01") }
      let(:dec) { Date.parse("2015-12-01") }

      context "which were added in the onboarding survey" do
        let(:extra_setup) do
          @opened_acc = \
            create(:open_survey_card_account,   opened_at: jan, person: person)
          @closed_acc = \
            create(:closed_survey_card_account, opened_at: mar, closed_at: oct, person: person)
        end

        let(:opened_acc) { AdminArea::CardAccountOnPage.new(@opened_acc, self) }
        let(:closed_acc) { AdminArea::CardAccountOnPage.new(@closed_acc, self) }

        it "lists them" do
          within "#admin_person_cards_from_survey" do
            expect(opened_acc).to be_present
            expect(closed_acc).to be_present
          end
          expect(opened_acc).to have_content "Open"
          expect(closed_acc).to have_content "Closed"
        end

        context "when an account is open" do
          it "says when it was opened" do
            is_expected.to have_selector \
              "##{dom_id(@opened_acc)} .card_account_opened_at", text: "Jan 2015"
          end

          it "has a '-' under 'Closed'" do
            is_expected.to have_selector \
              "##{dom_id(@opened_acc)} .card_account_closed_at", text: "-"
          end
        end

        context "when an account is closed" do
          it "says when it was opened and closed" do
            is_expected.to have_selector \
              "##{dom_id(@closed_acc)} .card_account_opened_at", text: "Mar 2015"
            is_expected.to have_selector \
              "##{dom_id(@closed_acc)} .card_account_closed_at", text: "Oct 2015"
          end
        end
      end

      context "which were added as recommendations" do
        let(:extra_setup) do
          @new_rec      = \
            create(:card_recommendation, recommended_at: jan, person: person)
          @clicked_rec  = \
            create(:card_recommendation, recommended_at: mar, clicked_at: oct, person: person)
          @declined_rec = \
            create(:card_recommendation, recommended_at: oct,
                   declined_at: dec, person: person, decline_reason: "because")
        end

        let(:new_rec)      { AdminArea::CardAccountOnPage.new(@new_rec, self) }
        let(:clicked_rec)  { AdminArea::CardAccountOnPage.new(@clicked_rec, self) }
        let(:declined_rec) { AdminArea::CardAccountOnPage.new(@declined_rec, self) }

        it "lists them" do
          within "#admin_person_card_recommendations" do
            expect(new_rec).to be_present
            expect(clicked_rec).to be_present
            expect(declined_rec).to be_present
          end
        end

        it "shows each card's status" do
          expect(new_rec).to have_status "Recommended"
          expect(clicked_rec).to have_status "Recommended"
          expect(declined_rec).to have_status "Declined"
        end

        it "shows the recommended/applied/opened/closed dates for each card" do
          expect(new_rec).to have_recommended_at_date("01/01/15")
          expect(new_rec).to have_no_clicked_at_date
          expect(new_rec).to have_no_applied_at_date

          expect(clicked_rec).to have_recommended_at_date("03/01/15")
          expect(clicked_rec).to have_clicked_at_date("10/01/15")
          expect(clicked_rec).to have_no_applied_at_date

          expect(declined_rec).to have_recommended_at_date("10/01/15")
          expect(declined_rec).to have_no_clicked_at_date
          expect(declined_rec).to have_declined_at_date("12/01/15")
        end

        context "when a recommendation has been declined" do
          it "shows the decline reason in a tooltip" do
            within declined_rec.dom_selector do
              is_expected.to have_selector "a[data-toggle='tooltip']"
              tooltip = find("a[data-toggle='tooltip']")
              expect(tooltip["title"]).to eq "because"
            end
          end
        end
      end
    end
  end

  example "person has not given their eligibility"
  example "person is ineligible"

  context "person is eligible" do
    example "and has not provided readiness"
    example "and is not ready (no reason given)"
    example "and is not ready (reason given)"
    example "and is ready"
  end


  describe "the card recommendation form" do
    let(:offers_on_page) { @offers.map { |o| AdminArea::RecommendableOfferOnPage.new(o, self) } }
    it "has an option to recommend each offer" do
      within ".admin-card-recommendation-table" do
        offers_on_page.each do |offer|
          expect(offer).to be_present
          expect(offer).to have_recommend_btn
        end
      end
    end

    it "doesn't contain dead offers" do
      expect(dead_offer).to be_absent
    end

    it "has a link to each offer (opens in new tab)" do
      offers_on_page.each do |offer_on_page|
        link = offer_on_page.offer.link
        expect(offer_on_page).to have_link "Link", href: link
        expect(offer_on_page.find("a[href='#{link}']")[:target]).to eq "_blank"
      end
    end

    describe "filters", :js do
      let(:filters) { AdminArea::CardRecommendationFiltersOnPage.new(self) }

      def have_recommendable_card(card)
        have_selector recommendable_card_selector(card)
      end

      def recommendable_card_selector(card)
        "##{dom_id(card, :admin_recommend)}"
      end

      def should_have_recommendable_cards(*cards)
        cards.each { |card| should have_recommendable_card(card) }
      end

      def should_not_have_recommendable_cards(*cards)
        cards.each { |card| should_not have_recommendable_card(card) }
      end

      describe "the cards" do
        specify "can be filtered by b/p" do
          filters.uncheck_business
          should_have_recommendable_cards(@chase_p, @usb_p)
          should_not_have_recommendable_cards(@chase_b, @usb_b)
          filters.uncheck_personal
          should_not_have_recommendable_cards(*@cards)
          filters.check_business
          should_have_recommendable_cards(@chase_b, @usb_b)
          should_not_have_recommendable_cards(@chase_p, @usb_p)
          filters.check_personal
          should_have_recommendable_cards(*@cards)
        end

        specify "can be filtered by bank" do
          Bank.all.each do |bank|
            is_expected.to have_field :"card_bank_filter_#{bank.id}"
          end

          filters.uncheck_chase
          should_have_recommendable_cards(@usb_b, @usb_p)
          should_not_have_recommendable_cards(@chase_b, @chase_p)
          filters.uncheck_us_bank
          should_not_have_recommendable_cards(*@cards)
          filters.check_chase
          should_have_recommendable_cards(@chase_b, @chase_p)
          should_not_have_recommendable_cards(@usb_b, @usb_p)
          filters.check_us_bank
          should_have_recommendable_cards(*@cards)
        end

        specify "can be filtered by currency" do
          Currency.pluck(:id).each do |currency_id|
            is_expected.to have_field :"card_currency_filter_#{currency_id}"
          end

          # TODO eh?
          uncheck "card_currency_filter_#{@chase_b.id}"
          uncheck "card_currency_filter_#{@chase_p.id}"
          should_have_recommendable_cards(@usb_p, @usb_p)
          should_not_have_recommendable_cards(@chase_b, @chase_p)
          uncheck "card_currency_filter_#{@usb_b.id}"
          uncheck "card_currency_filter_#{@usb_p.id}"
          should_not_have_recommendable_cards(*@cards)
          check "card_currency_filter_#{@chase_p.id}"
          should_have_recommendable_cards(@chase_p)
        end
      end

      describe "the 'toggle all banks' checkbox" do
        it "toggles all banks on/off" do
          filters.uncheck_all_banks
          should_not_have_recommendable_cards(*@cards)
          Bank.all.each do |bank|
            expect(find("#card_bank_filter_#{bank.id}")).not_to be_checked
          end
          filters.check_all_banks
          should_have_recommendable_cards(*@cards)
          Bank.all.each do |bank|
            expect(find("#card_bank_filter_#{bank.id}")).to be_checked
          end
        end

        it "is checked/unchecked automatically as I click other CBs" do
          filters.uncheck_chase
          expect(filters.all_banks_check_box).not_to be_checked
          filters.check_chase
          expect(filters.all_banks_check_box).to be_checked
        end
      end
    end # filters

    describe "clicking 'recommend' next to an offer", :js do
      let(:offer) { @offers[3] }
      let(:offer_on_page) { AdminArea::RecommendableOfferOnPage.new(offer, self) }

      before { offer_on_page.click_recommend_btn }

      it "shows confirm/cancel buttons" do
        expect(offer_on_page).to have_no_button "Recommend"
        expect(offer_on_page).to have_button "Cancel"
        expect(offer_on_page).to have_button "Confirm"
      end

      describe "clicking 'Confirm'" do
        it "recommends that card to the person" do
          expect{offer_on_page.click_confirm_btn}.to change{
            CardAccount.recommendations.count
          }.by(1)
        end

        describe "the new recommendation" do
          before { offer_on_page.click_confirm_btn }


          it "has the correct attributes" do
            rec = CardAccount.recommendations.last
            expect(rec.card).to eq offer.card
            expect(rec.offer).to eq offer
            expect(rec.person).to eq @person
            expect(rec.recommended_at).to eq Date.today
            expect(rec.recommendation?).to be true
          end
        end
      end # clicking 'Confirm'

      describe "clicking 'Cancel'" do
        it "doesn't recommend the card to the person" do
          expect{offer_on_page.click_cancel_btn}.not_to change{CardAccount.count}
        end

        it "shows the 'recommend' button again" do
          offer_on_page.click_cancel_btn
          expect(offer_on_page).to have_button "Recommend"
          expect(offer_on_page).to have_no_button "Confirm"
          expect(offer_on_page).to have_no_button "Cancel"
        end
      end
    end
  end

  it "has a button to mark recommendations as complete" do
    is_expected.to have_selector "input[value=Done][type=submit]"
  end

  context "when the person has not received any recommendations before" do
    before { raise if person.last_recommendations_at.present? }
    it "doesn't display a 'last recs' timestamp" do
      is_expected.to have_no_selector ".person_last_recommendations_at"
    end
  end

  context "when the person has received recommendations before" do
    let(:date) { 5.days.ago }
    let(:extra_setup) { person.update_attributes!(last_recommendations_at: date) }

    it "displays a 'last recs' timestamp" do
      is_expected.to have_selector(
        ".person_last_recommendations_at",
        text: date.strftime("%D"),
      )
    end
  end

  context "when the user has no existing recommendation notes" do
    it "doesn't display the recommendation notes panel" do
      expect(page).to have_no_content "Recommendation Notes"
    end
  end

  describe "when the user has existing recommendation notes" do
    let(:no_of_existing_notes) { 3 }

    it "displays them" do
      expect(page).to have_content("Recommendation Notes")
      account.recommendation_notes.each do |note|
        expect(page).to have_content note.created_at
        expect(page).to have_content note.content
      end
    end
  end

  it "has a text input for Recommendation Notes" do
    expect(page).to have_field :recommendation_note
  end

  describe "clicking 'Done'" do
    let(:click_done) { click_button "Done" }
    let(:new_notification) { account.notifications.last }

    it "sends a notification to the user" do
      expect{click_done}.to change{account.notifications.count}.by(1)
      expect(new_notification).to be_a(Notifications::NewRecommendations)
      expect(new_notification.record).to eq person
    end

    it "sends an email to the user" do
      pending
      expect{click_done}.to change { enqueued_jobs.size }.by(1)

      expect do
        perform_enqueued_jobs { ActionMailer::DeliveryJob.perform_now(*enqueued_jobs.first[:args]) }
      end.to change {(ApplicationMailer.deliveries.length)}.by(1)

      email = ApplicationMailer.deliveries.last
      expect(email.subject).to eq "something"
    end

    it "updates the person's 'last recs' timestamp" do
      click_done
      expect(person.reload.last_recommendations_at).to be_within(5.seconds).of(Time.now)
    end

    it "increments the account's unseen_notifications_count" do
      expect do
        click_done
        account.reload
      end.to change{account.unseen_notifications_count}.by(1)
    end

    context "when I've added a recommendation note" do
      let(:new_note) {"I like to leave notes."}
      before { fill_in :recommendation_note, with: new_note }

      it "sends the note to the user" do
        expect do
          click_done
          account.recommendation_notes.reload
        end.to change{account.recommendation_notes.count}.by(1)
        expect(account.recommendation_notes.order(:created_at).last.content).to eq new_note
      end

      context "with trailing whitespace" do
        let(:new_note) { "  I like to leave notes.  " }

        it "strips whitespace before save" do
          click_done
          note = account.recommendation_notes.order(:created_at).last
          expect(note.content).to eq new_note.strip
        end
      end
    end

    context "when I haven't added a recommendation note" do
      it "doesn't add a recommendation note to the user" do
        expect{click_done}.to_not change{account.recommendation_notes.reload.count}
      end
    end

    context "filling in the recommendation note input with whitespace" do
      before { fill_in :recommendation_note, with: "     \n \n \t\ \t " }

      it "doesn't add a recommendation note to the user" do
        expect{click_done}.to_not change{@account.recommendation_notes.reload.count}
      end
    end
  end

end
