require "rails_helper"

module AdminArea
  describe "admin section - person page", :manual_clean do
    include_context "logged in as admin"

    let(:aw_email) { "totallyawesomedude@example.com" }

    before(:all) do
      @chase   = Bank.find_by(name: "Chase")
      @us_bank = Bank.find_by(name: "US Bank")
      @one_world_alliance = Alliance.find_by(name: "OneWorld")
      @sky_team_alliance  = Alliance.find_by(name: "SkyTeam")

      @currencies = []
      @currencies << create(:currency, alliance_id: @one_world_alliance.id)
      @currencies << create(:currency, alliance_id: @sky_team_alliance.id)
      @currencies << create(:currency, alliance_id: @one_world_alliance.id)
      @currencies << create(:currency, alliance_id: nil)

      def create_card(bp, bank, currency)
        create(:card, bp, bank_id: bank.id, currency: currency)
      end

      @cards = [
        @chase_b = create_card(:business, @chase,   @currencies[0]),
        @chase_p = create_card(:personal, @chase,   @currencies[1]),
        @usb_b   = create_card(:business, @us_bank, @currencies[2]),
        @usb_p   = create_card(:personal, @us_bank, @currencies[3]),
      ]

      @independent_card = [@usb_p]
      @one_world_cards = [@chase_b, @usb_b]
      @sky_team_cards = [@chase_p]

      @offers = [
        create(:offer, card: @chase_b),
        create(:offer, card: @chase_b),
        create(:offer, card: @chase_p),
        create(:offer, card: @usb_b),
        create(:offer, card: @usb_p),
      ]
      @dead_offer = create(:dead_offer, card: @chase_b)
    end

    before do
      @person = create(
        :person,
        :eligible,
        award_wallet_email: aw_email,
      )
      @account = @person.account.reload
      @account.update!(onboarding_state: :complete)
    end

    def visit_path
      visit admin_person_path(@person)
    end

    let(:recommend_link_text) { "Recommend a card" }
    let(:account) { @account }
    let(:person)  { @person }
    let(:name)    { @person.first_name }
    let(:chase)   { @chase }
    let(:us_bank) { @us_bank }
    let(:offers)  { @offers }

    let(:dead_offer) { RecommendableOfferOnPage.new(@dead_offer, self) }

    let(:complete_card_recs_form) { CompleteCardRecsFormOnPage.new(self) }

    example "basic information" do
      visit_path
      expect(page).to have_title full_title(@person.first_name)
      expect(page).to have_content @account.created_at.strftime("%D")
      # person's name as the page header
      expect(page).to have_selector "h1", text: name
      # award wallet email
      expect(page).to have_content "AwardWallet email: #{aw_email}"
    end

    example "person with no spending info" do
      visit_path
      expect(page).to have_content "User has not added their spending info"
    end

    example "person with spending info" do
      person.create_spending_info!(
        credit_score: 678,
        has_business: :with_ein,
        business_spending_usd: 1500,
      )
      visit_path
      expect(page).to have_content "Credit score: 678"
      expect(page).to have_content "Will apply for loan in next 6 months: No"
      expect(page).to have_content "Business spending: $1,500.00"
      expect(page).to have_content "(Has EIN)"
    end

    it "says whether this is the owner or companion passenger"

    example "person with no travel plans" do
      visit_path
      expect(page).to have_content "User has no upcoming travel plans"
      expect(page).to have_no_link("Edit")
    end

    # TODO this isn't really the best place to put this test; it's testing
    # the travel_plan/travel_plan partial, which is used on other pages.
    example "person with travel plans" do
      @eu  = create(:region,  name: "Europe")
      @uk  = create(:country, name: "UK",     parent: @eu)
      @lon = create(:city,    name: "London", parent: @uk)
      @lhr = create(:airport, name: "Heathrow", code: "LHR", parent: @lon)

      @as  = create(:region,  name: "Asia")
      @vn  = create(:country, name: "Vietnam", parent: @as)
      @hcm = create(:city,    name: "Ho Chi Minh City", parent: @vn)
      @sgn = create(:airport, name: "HCMC", code: "SGN", parent: @hcm)

      @na  = create(:region,  name: "North America")
      @us  = create(:country, name: "United States", parent: @na)
      @nyc = create(:city,    name: "New York City", parent: @us)
      @jfk = create(:airport, name: "John F Kennedy", code: "JFK", parent: @nyc)

      # Currently users can only create travel plans that are from/to airports
      # Legacy data will be to/from countries, but don't bother testing that
      # here.

      @tp_0 = create(
        :travel_plan, :single, account: @account,
        flights: [Flight.new(from: @jfk, to: @lhr)],
      )
      @tp_1 = create(
        :travel_plan, :return, account: @account,
        flights: [Flight.new(from: @sgn, to: @jfk)],
      )

      visit_path

      expect(page).to have_no_content "User has no upcoming travel plans"

      within ".account_travel_plans" do
        expect(page).to have_selector "##{dom_id(@tp_0)}"
        within "##{dom_id(@tp_0)}" do
          expect(page).to have_content "Single"
          expect(page).to have_selector "##{dom_id(@tp_0.flights[0])}"
          within "##{dom_id(@tp_0.flights[0])}" do
            expect(page).to have_content "New York City (JFK) - North America"
            expect(page).to have_content "London (LHR) - Europe"
          end
          # TODO temporarily disabled
          # expect(page).to have_link("Edit", href: edit_admin_travel_plan_path(@tp_0))
        end

        expect(page).to have_selector "##{dom_id(@tp_1)}"
        within "##{dom_id(@tp_1)}" do
          expect(page).to have_content "Return"
          expect(page).to have_selector "##{dom_id(@tp_1.flights[0])}"
          within "##{dom_id(@tp_1.flights[0])}" do
            expect(page).to have_content "Ho Chi Minh City (SGN) - Asia"
            expect(page).to have_content "New York City (JFK) - North America"
          end
          # TODO temporarily disabled
          # expect(page).to have_link("Edit", href: edit_admin_travel_plan_path(@tp_1))
        end
      end
    end

    example "person with no points balances" do
      visit_path
      expect(page).to have_content t("admin.people.card_recommendations.no_balances")
    end

    example "person with points balances" do
      Balance.create!(
        person: @person, currency: @currencies[0], value:  5000,
      )
      Balance.create!(
        person: @person, currency: @currencies[2], value: 10_000,
      )
      visit_path

      expect(page).to have_selector "##{dom_id(@currencies[0])} .balance",
                                    text: "5,000"
      expect(page).to have_selector "##{dom_id(@currencies[2])} .balance",
                                    text: "10,000"

      expect(page).to have_no_selector "##{dom_id(@currencies[1])}_balance"
      expect(page).to have_no_selector "##{dom_id(@currencies[3])}_balance"
    end

    let(:jan) { Date.parse("2015-01-01") }
    let(:mar) { Date.parse("2015-03-01") }
    let(:oct) { Date.parse("2015-10-01") }
    let(:dec) { Date.parse("2015-12-01") }

    example "person added cards in onboarding survey" do
      @opened_acc = \
        create(:open_survey_card_account,   opened_at: jan, person: person)
      @closed_acc = \
        create(:closed_survey_card_account, opened_at: mar, closed_at: oct, person: person)

      visit_path

      opened_acc = CardAccountOnPage.new(@opened_acc, self)
      closed_acc = CardAccountOnPage.new(@closed_acc, self)

      within "#admin_person_card_accounts" do
        expect(opened_acc).to be_present
        expect(closed_acc).to be_present
      end
      expect(opened_acc).to have_status "Open"
      expect(closed_acc).to have_status "Closed"
      # says when they were opened/closed:
      expect(opened_acc).to have_opened_at_date("Jan 2015")
      expect(opened_acc).to have_no_closed_at_date
      expect(closed_acc).to have_opened_at_date("Mar 2015")
      expect(closed_acc).to have_closed_at_date("Oct 2015")
    end

    example "person has received recommendations" do
      @new_rec = person.card_recommendations.create!(
        offer: offers[0], recommended_at: jan, person: person,
      )
      @clicked_rec = person.card_recommendations.create!(
        offer: offers[0], seen_at: jan, recommended_at: mar, clicked_at: oct,
      )
      @declined_rec = person.card_recommendations.create!(
        offer: offers[0], recommended_at: oct, seen_at: mar, declined_at: dec, decline_reason: "because",
      )

      last_recs_date = 5.days.ago
      person.update_attributes!(last_recommendations_at: last_recs_date)

      visit_path

      new_rec      = CardAccountOnPage.new(@new_rec, self)
      clicked_rec  = CardAccountOnPage.new(@clicked_rec, self)
      declined_rec = CardAccountOnPage.new(@declined_rec, self)

      within "#admin_person_card_accounts_table" do
        expect(new_rec).to be_present
        expect(clicked_rec).to be_present
        expect(declined_rec).to be_present
      end

      # shows each card's status:
      expect(new_rec).to have_status "Recommended"
      expect(clicked_rec).to have_status "Recommended"
      expect(declined_rec).to have_status "Declined"

      # shows the recommended/applied/opened/closed dates:
      expect(new_rec).to have_recommended_at_date("01/01/15")
      expect(new_rec).to have_no_seen_at_date
      expect(new_rec).to have_no_clicked_at_date
      expect(new_rec).to have_no_applied_at_date

      expect(clicked_rec).to have_recommended_at_date("03/01/15")
      expect(clicked_rec).to have_seen_at_date("01/01/15")
      expect(clicked_rec).to have_clicked_at_date("10/01/15")
      expect(clicked_rec).to have_no_applied_at_date

      expect(declined_rec).to have_recommended_at_date("10/01/15")
      expect(declined_rec).to have_seen_at_date("03/01/15")
      expect(declined_rec).to have_no_clicked_at_date
      expect(declined_rec).to have_declined_at_date("12/01/15")

      # shows decline reasons in a tooltip:
      expect(declined_rec).to have_selector "a[data-toggle='tooltip']"
      tooltip = declined_rec.find("a[data-toggle='tooltip']")
      expect(tooltip["title"]).to eq "because"

      # displays the last recs timestamp:
      expect(page).to have_selector(
        ".person_last_recommendations_at",
        text: last_recs_date.strftime("%D"),
      )
    end

    example "person has not received recommendations" do
      visit_path
      # sanity check:
      raise if person.last_recommendations_at.present?

      # no last recs timestamp:
      expect(page).to have_no_selector ".person_last_recommendations_at"
    end

    example "person has not given their eligibility"
    example "person is ineligible"

    context "person is eligible" do
      example "and has not provided readiness"
      example "and is not ready (no reason given)"
      example "and is not ready (reason given)"
      example "and is ready"
    end

    example "pulled recs", :js do
      o = offers[0]
      pulled_rec   = create(:card_recommendation, :pulled, offer: o, person: person)
      unpulled_rec = create(:card_recommendation, offer: o, person: person)
      visit_path

      pulled_rec_on_page   = AdminArea::CardAccountOnPage.new(pulled_rec, self)
      unpulled_rec_on_page = AdminArea::CardAccountOnPage.new(unpulled_rec, self)

      expect(pulled_rec_on_page).to be_absent
      expect(unpulled_rec_on_page).to be_present
      expect(page).to have_link "View 1 pulled recommendation"
    end

    example "pulling a rec", :js do
      rec = create(:card_recommendation, offer: offers[0], person: person)
      visit_path
      rec_on_page = AdminArea::CardAccountOnPage.new(rec, self)

      page.accept_confirm do
        rec_on_page.click_pull_btn
      end

      expect(rec_on_page).to be_absent
      expect(rec.reload.pulled_at).to be_within(5.seconds).of(Time.now)
    end

    let(:offers_on_page) { @offers.map { |o| RecommendableOfferOnPage.new(o, self) } }

    specify "page has buttons to recommend each live offer" do
      visit_path
      within ".admin-card-recommendation-table" do
        offers_on_page.each do |offer_on_page|
          expect(offer_on_page).to be_present
          expect(offer_on_page).to have_recommend_btn
          link = offer_on_page.offer.link
          expect(offer_on_page).to have_link "Link", href: link
          expect(offer_on_page.find("a[href='#{link}']")[:target]).to eq "_blank"
        end
      end

      expect(dead_offer).to be_absent
    end

    describe "the card recommendation form" do
      before { visit_path }

      describe "filters", :js do
        let(:filters) { CardRecommendationFiltersOnPage.new(self) }

        def have_recommendable_card(card)
          have_selector recommendable_card_selector(card)
        end

        def recommendable_card_selector(card)
          "##{dom_id(card, :admin_recommend)}"
        end

        def page_should_have_recommendable_cards(*cards)
          cards.each { |card| expect(page).to have_recommendable_card(card) }
        end

        def page_should_not_have_recommendable_cards(*cards)
          cards.each { |card| expect(page).not_to have_recommendable_card(card) }
        end

        example "filtering by b/p" do
          filters.uncheck_business
          page_should_have_recommendable_cards(@chase_p, @usb_p)
          page_should_not_have_recommendable_cards(@chase_b, @usb_b)
          filters.uncheck_personal
          page_should_not_have_recommendable_cards(*@cards)
          filters.check_business
          page_should_have_recommendable_cards(@chase_b, @usb_b)
          page_should_not_have_recommendable_cards(@chase_p, @usb_p)
          filters.check_personal
          page_should_have_recommendable_cards(*@cards)
        end

        example "filtering by bank" do
          Bank.all.each do |bank|
            expect(page).to have_field :"card_bank_filter_#{bank.id}"
          end

          filters.uncheck_chase
          page_should_have_recommendable_cards(@usb_b, @usb_p)
          page_should_not_have_recommendable_cards(@chase_b, @chase_p)
          filters.uncheck_us_bank
          page_should_not_have_recommendable_cards(*@cards)
          filters.check_chase
          page_should_have_recommendable_cards(@chase_b, @chase_p)
          page_should_not_have_recommendable_cards(@usb_b, @usb_p)
          filters.check_us_bank
          page_should_have_recommendable_cards(*@cards)
        end

        example "filtering by currency" do
          Currency.pluck(:id).each do |currency_id|
            expect(page).to have_field :"card_currency_filter_#{currency_id}"
          end

          # TODO eh?
          uncheck "card_currency_filter_#{@chase_b.id}"
          uncheck "card_currency_filter_#{@chase_p.id}"
          page_should_have_recommendable_cards(@usb_p, @usb_p)
          page_should_not_have_recommendable_cards(@chase_b, @chase_p)
          uncheck "card_currency_filter_#{@usb_b.id}"
          uncheck "card_currency_filter_#{@usb_p.id}"
          page_should_not_have_recommendable_cards(*@cards)
          check "card_currency_filter_#{@chase_p.id}"
          page_should_have_recommendable_cards(@chase_p)
        end

        example "toggling all banks" do
          filters.uncheck_all_banks
          page_should_not_have_recommendable_cards(*@cards)
          Bank.all.each do |bank|
            expect(find("#card_bank_filter_#{bank.id}")).not_to be_checked
          end
          filters.check_all_banks
          page_should_have_recommendable_cards(*@cards)
          Bank.all.each do |bank|
            expect(find("#card_bank_filter_#{bank.id}")).to be_checked
          end

          # it gets checked/unchecked automatically as I click other CBs:
          filters.uncheck_chase
          expect(filters.all_banks_check_box).not_to be_checked
          filters.check_chase
          expect(filters.all_banks_check_box).to be_checked
        end

        example "toggling all currencies" do
          filters.uncheck_all_independent_currencies
          filters.uncheck_all_one_world_currencies
          filters.uncheck_all_sky_team_currencies

          page_should_not_have_recommendable_cards(*@cards)
          Currency.all.each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
          end

          filters.check_all_independent_currencies
          filters.check_all_one_world_currencies
          filters.check_all_sky_team_currencies

          page_should_have_recommendable_cards(*@cards)
          Currency.all.each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).to be_checked
          end
        end

        example "toggling all independent currencies" do
          filters.uncheck_all_independent_currencies
          page_should_not_have_recommendable_cards(*@independent_card)
          Currency.where(alliance_id: nil).each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
          end
          filters.check_all_independent_currencies
          page_should_have_recommendable_cards(*@independent_card)
          Currency.where(alliance_id: nil).each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).to be_checked
          end

          # it gets checked/unchecked automatically as I click other CBs:
          filters.uncheck "card_currency_filter_#{@independent_card[0].id}"
          expect(filters.all_independent_currencies_check_box).not_to be_checked
          filters.check "card_currency_filter_#{@independent_card[0].id}"
          expect(filters.all_independent_currencies_check_box).to be_checked
        end

        example "toggling all one world alliance currencies" do
          filters.uncheck_all_one_world_currencies
          page_should_not_have_recommendable_cards(*@one_world_cards)
          Currency.where(alliance_id: @one_world_alliance.id).each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
          end
          filters.check_all_one_world_currencies
          page_should_have_recommendable_cards(*@one_world_cards)
          Currency.where(alliance_id: @one_world_alliance.id).each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).to be_checked
          end

          # it gets checked/unchecked automatically as I click other CBs:
          filters.uncheck "card_currency_filter_#{@one_world_cards[0].id}"
          expect(filters.all_one_world_currencies_check_box).not_to be_checked
          filters.check "card_currency_filter_#{@one_world_cards[0].id}"
          expect(filters.all_one_world_currencies_check_box).to be_checked
        end
      end

      let(:offer) { @offers[3] }
      let(:offer_on_page) { RecommendableOfferOnPage.new(offer, self) }

      example "confirmation when clicking 'recommend'", :js do
        # clicking 'recommend' shows confirm/cancel buttons
        offer_on_page.click_recommend_btn
        expect(offer_on_page).to have_no_button "Recommend"
        expect(offer_on_page).to have_button "Cancel"
        expect(offer_on_page).to have_button "Confirm"

        # clicking 'cancel' goes back a step, and doesn't recommend anything
        expect { offer_on_page.click_cancel_btn }.not_to change { CardAccount.count }
        expect(offer_on_page).to have_button "Recommend"
        expect(offer_on_page).to have_no_button "Confirm"
        expect(offer_on_page).to have_no_button "Cancel"
      end

      example "recommending an offer", :js do
        offer_on_page.click_recommend_btn

        # it recommends the card to the person
        expect do
          offer_on_page.click_confirm_btn
          wait_for_ajax
        end.to change { @person.card_recommendations.count }.by(1)

        expect(page).to have_content "Recommended!"

        # the rec has the correct attributes:
        rec = CardAccount.recommendations.last
        expect(rec.card).to eq offer.card
        expect(rec.offer).to eq offer
        expect(rec.person).to eq @person
        expect(rec.recommended_at).to eq Date.today
        expect(rec.recommendation?).to be true

        # the rec is added to the table:
        within "#admin_person_card_accounts_table" do
          expect(page).to have_selector "#card_account_#{rec.id}"
        end
      end
    end

    it "doesn't display the recommendation notes panel when account has no notes" do
      visit_path
      expect(page).to have_no_content "Recommendation Notes"
    end

    example "displaying recommendation notes" do
      create_list(:recommendation_note, 3, account: account)
      visit_path
      expect(page).to have_content "Recommendation Notes"
      account.recommendation_notes.each do |note|
        expect(page).to have_content note.created_at
        expect(page).to have_content note.content
      end
    end

    example "marking recommendations as complete" do
      visit_path
      expect do
        complete_card_recs_form.submit
        account.reload
      end.to \
        change { account.notifications.count }.by(1).and \
          change { account.unseen_notifications_count }.by(1).and \
            send_email.to(account.email).with_subject("Action Needed: Card Recommendations Ready")

      new_notification = account.notifications.order(created_at: :asc).last

      # it sends a notification to the user:
      expect(new_notification).to be_a(Notifications::NewRecommendations)
      expect(new_notification.record).to eq person

      # it updates the person's 'last recs' timestamp:
      person.reload
      expect(person.last_recommendations_at).to be_within(5.seconds).of(Time.now)
    end

    example "clicking 'Done' without adding a recommendation note to the user" do
      visit_path
      expect { complete_card_recs_form.submit }.to_not change { account.recommendation_notes.count }
    end

    example "sending a recommendation note to the user" do
      visit_path
      expect(page).to have_field :recommendation_note

      note_content = "I like to leave notes."
      complete_card_recs_form.add_rec_note(note_content)

      # it sends the note to the user:
      expect do
        complete_card_recs_form.submit
      end.to \
        change { account.recommendation_notes.count }.by(1).and \
          send_email.to(account.email).with_subject("Action Needed: Card Recommendations Ready")

      email = ApplicationMailer.deliveries.last
      expect(email.body).to include note_content

      new_note = account.recommendation_notes.order(created_at: :asc).last
      expect(new_note.content).to eq note_content
    end

    example "recommendation note with trailing whitespace" do
      visit_path
      note_content = "  I like to leave notes.   "
      complete_card_recs_form.add_rec_note(note_content)
      complete_card_recs_form.submit

      new_note = account.recommendation_notes.order(created_at: :asc).last
      expect(new_note.content).to eq note_content.strip
    end

    example "recommendation note that's only whitespace" do
      visit_path
      complete_card_recs_form.add_rec_note("     \n \n \t\ \t ")
      expect do
        complete_card_recs_form.submit
      end.to_not change { account.recommendation_notes.count }
    end
  end
end
