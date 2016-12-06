require "rails_helper"

module AdminArea
  describe "admin section - person page", :manual_clean do
    include_context "logged in as admin"

    let(:aw_email) { "totallyawesomedude@example.com" }

    before(:all) do
      @chase   = create(:bank, name: "Chase")
      @us_bank = create(:bank, name: "US Bank")
      # There's no practical difference between the 'Independent' alliance
      # (i.e. no Alliance) and real Alliances; no need to test Independent
      @one_world = Alliance.create!(name: 'OneWorld', order: 0)
      @sky_team  = Alliance.create!(name: 'SkyTeam',  order: 1)

      @currencies = []
      @currencies << create(:currency, alliance: @one_world)
      @currencies << create(:currency, alliance: @sky_team)
      @currencies << create(:currency, alliance: @one_world)

      def create_product(bp, bank, currency)
        create(:card_product, bp, bank_id: bank.id, currency: currency)
      end

      @products = [
        @chase_b = create_product(:business, @chase,   @currencies[0]),
        @chase_p = create_product(:personal, @chase,   @currencies[1]),
        @usb_b   = create_product(:business, @us_bank, @currencies[2]),
      ]

      @one_world_cards = [@chase_b, @usb_b]
      @sky_team_cards = [@chase_p]

      @offers = [
        create(:offer, product: @chase_b),
        create(:offer, product: @chase_b),
        create(:offer, product: @chase_p),
        create(:offer, product: @usb_b),
      ]
      @dead_offer = create(:dead_offer, product: @chase_b)
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

    let(:jan) { Date.parse("2015-01-01") }
    let(:mar) { Date.parse("2015-03-01") }
    let(:oct) { Date.parse("2015-10-01") }
    let(:dec) { Date.parse("2015-12-01") }

    example "person added cards in onboarding survey" do
      @opened_acc = \
        create(:open_survey_card,   opened_at: jan, person: person)
      @closed_acc = \
        create(:closed_survey_card, opened_at: mar, closed_at: oct, person: person)

      visit_path

      opened_acc_selector = '#' << dom_id(@opened_acc)
      closed_acc_selector = '#' << dom_id(@closed_acc)

      within "#admin_person_cards" do
        expect(page).to have_selector opened_acc_selector
        expect(page).to have_selector closed_acc_selector
      end

      within opened_acc_selector do
        expect(page).to have_selector '.card_opened_at', text: 'Jan 2015'
        expect(page).to have_selector '.card_closed_at', text: '-'
        expect(page).to have_selector '.card_status', text: 'Open'
      end

      within closed_acc_selector do
        expect(page).to have_selector '.card_status', text: 'Closed'
        # says when they were opened/closed:
        expect(page).to have_selector '.card_opened_at', text: 'Mar 2015'
        expect(page).to have_selector '.card_closed_at', text: 'Oct 2015'
      end
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

      new_rec_selector      = '#' << dom_id(@new_rec)
      clicked_rec_selector  = '#' << dom_id(@clicked_rec)
      declined_rec_selector = '#' << dom_id(@declined_rec)

      within "#admin_person_cards_table" do
        expect(page).to have_selector new_rec_selector
        expect(page).to have_selector clicked_rec_selector
        expect(page).to have_selector declined_rec_selector
      end

      within new_rec_selector do
        expect(page).to have_selector '.card_status', text: 'Recommended'
        expect(page).to have_selector '.card_recommended_at', text: '01/01/15'
        expect(page).to have_selector '.card_seen_at',        text: '-'
        expect(page).to have_selector '.card_clicked_at',     text: '-'
        expect(page).to have_selector '.card_applied_at',     text: '-'
      end

      within clicked_rec_selector do
        expect(page).to have_selector '.card_recommended_at', text: '03/01/15'
        expect(page).to have_selector '.card_seen_at',        text: '01/01/15'
        expect(page).to have_selector '.card_clicked_at',     text: '10/01/15'
        expect(page).to have_selector '.card_applied_at',     text: '-'
        expect(page).to have_selector '.card_status', text: 'Recommended'
      end

      within declined_rec_selector do
        expect(page).to have_selector '.card_recommended_at', text: '10/01/15'
        expect(page).to have_selector '.card_seen_at',        text: '03/01/15'
        expect(page).to have_selector '.card_clicked_at',     text: '-'
        expect(page).to have_selector '.card_declined_at',    text: '12/01/15'
        expect(page).to have_selector '.card_status', text: 'Declined'
        expect(page).to have_selector "a[data-toggle='tooltip']"
        expect(find("a[data-toggle='tooltip']")["title"]).to eq "because"
      end

      # displays the last recs timestamp:
      expect(page).to have_selector(
        ".person_last_recommendations_at",
        text: last_recs_date.strftime("%D"),
      )
    end

    example "person has not received recommendations" do
      visit_path
      # sanity check:
      raise unless person.last_recommendations_at.nil?

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

      expect(page).to have_no_selector "##{dom_id(pulled_rec)}"
      expect(page).to have_selector "##{dom_id(unpulled_rec)}"
      expect(page).to have_link 'View 1 pulled recommendation'
    end

    example "pulling a rec", :js do
      rec = create(:card_recommendation, offer: offers[0], person: person)
      visit_path

      page.accept_confirm do
        find("#card_#{rec.id}_pull_btn").click
      end

      expect(page).to have_no_selector "##{dom_id(rec)}"
      expect(rec.reload.pulled_at).to be_within(5.seconds).of(Time.zone.now)
    end

    describe "the card recommendation form" do
      before { visit_path }

      describe "filters", :js do
        let(:business_check_box) { :card_bp_filter_business }
        let(:personal_check_box) { :card_bp_filter_personal }
        let(:all_banks) { :card_bank_filter_all }
        let(:all_ow) { :"card_currency_alliance_filter_all_for_#{@one_world.id}" }
        let(:all_st) { :"card_currency_alliance_filter_all_for_#{@sky_team.id}" }
        let(:chase_check_box)   { :"card_bank_filter_#{@chase.id}" }
        let(:us_bank_check_box) { :"card_bank_filter_#{@us_bank.id}" }

        def recommendable_card_product_selector(product)
          '#' << dom_id(product, :admin_recommend)
        end

        def page_should_have_recommendable_products(*products)
          products.each do |product|
            expect(page).to have_selector recommendable_card_product_selector(product)
          end
        end

        def page_should_not_have_recommendable_products(*products)
          products.each do |product|
            expect(page).to have_no_selector recommendable_card_product_selector(product)
          end
        end

        example "filtering by b/p" do
          uncheck business_check_box
          page_should_have_recommendable_products(@chase_p)
          page_should_not_have_recommendable_products(@chase_b, @usb_b)
          uncheck personal_check_box
          page_should_not_have_recommendable_products(*@products)
          check business_check_box
          page_should_have_recommendable_products(@chase_b, @usb_b)
          page_should_not_have_recommendable_products(@chase_p)
          check personal_check_box
          page_should_have_recommendable_products(*@products)
        end

        example "filtering by bank" do
          Bank.all.each do |bank|
            expect(page).to have_field :"card_bank_filter_#{bank.id}"
          end

          uncheck chase_check_box
          page_should_have_recommendable_products(@usb_b)
          page_should_not_have_recommendable_products(@chase_b, @chase_p)
          uncheck us_bank_check_box
          page_should_not_have_recommendable_products(*@products)
          check chase_check_box
          page_should_have_recommendable_products(@chase_b, @chase_p)
          page_should_not_have_recommendable_products(@usb_b)
          check us_bank_check_box
          page_should_have_recommendable_products(*@products)
        end

        example "filtering by currency" do
          Currency.pluck(:id).each do |currency_id|
            expect(page).to have_field :"card_currency_filter_#{currency_id}"
          end

          # TODO eh?
          uncheck "card_currency_filter_#{@chase_b.id}"
          uncheck "card_currency_filter_#{@chase_p.id}"
          page_should_not_have_recommendable_products(@chase_b, @chase_p)
          uncheck "card_currency_filter_#{@usb_b.id}"
          page_should_not_have_recommendable_products(*@products)
          check "card_currency_filter_#{@chase_p.id}"
          page_should_have_recommendable_products(@chase_p)
        end

        example "toggling all banks" do
          uncheck all_banks
          page_should_not_have_recommendable_products(*@products)
          Bank.all.each do |bank|
            expect(find("#card_bank_filter_#{bank.id}")).not_to be_checked
          end
          check all_banks
          page_should_have_recommendable_products(*@products)
          Bank.all.each do |bank|
            expect(find("#card_bank_filter_#{bank.id}")).to be_checked
          end

          # it gets checked/unchecked automatically as I click other CBs:
          uncheck chase_check_box
          expect(find("##{all_banks}")).not_to be_checked
          check chase_check_box
          expect(find("##{all_banks}")).to be_checked
        end

        example "toggling all currencies" do
          uncheck all_ow
          uncheck all_st

          page_should_not_have_recommendable_products(*@products)
          Currency.all.each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
          end

          check all_ow
          check all_st

          page_should_have_recommendable_products(*@products)
          Currency.all.each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).to be_checked
          end
        end

        example "toggling all one world alliance currencies" do
          uncheck all_ow
          page_should_not_have_recommendable_products(*@one_world_cards)
          Currency.where(alliance_id: @one_world.id).each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
          end
          check all_ow
          page_should_have_recommendable_products(*@one_world_cards)
          Currency.where(alliance_id: @one_world.id).each do |currency|
            expect(find("#card_currency_filter_#{currency.id}")).to be_checked
          end

          # it gets checked/unchecked automatically as I click other CBs:
          uncheck "card_currency_filter_#{@one_world_cards[0].id}"
          expect(find("##{all_ow}")).not_to be_checked
          check "card_currency_filter_#{@one_world_cards[0].id}"
          expect(find("##{all_ow}")).to be_checked
        end
      end

      let(:offer) { @offers[3] }
      let(:offer_selector) { "##{dom_id(offer, :admin_recommend)}" }

      example 'confirmation when clicking "recommend"', :js do
        # clicking 'recommend' shows confirm/cancel buttons
        within offer_selector do
          click_button 'Recommend'
          expect(page).to have_no_button 'Recommend'
          expect(page).to have_button 'Cancel'
          expect(page).to have_button 'Confirm'

          # clicking 'cancel' goes back a step, and doesn't recommend anything
          expect { click_button 'Cancel' }.not_to change { ::Card.count }
          expect(page).to have_button 'Recommend'
          expect(page).to have_no_button 'Confirm'
          expect(page).to have_no_button 'Cancel'
        end
      end

      # TODO extract to a Trailblazer operation called Recommendation::Create
      example "recommending an offer", :js do
        within offer_selector do
          click_button 'Recommend'
        end

        # it recommends the card to the person
        expect do
          within offer_selector do
            click_button 'Confirm'
          end
          wait_for_ajax
        end.to change { @person.card_recommendations.count }.by(1)

        expect(page).to have_content "Recommended!"

        # the rec has the correct attributes:
        rec = ::Card.recommendations.last
        expect(rec.product).to eq offer.product
        expect(rec.offer).to eq offer
        expect(rec.person).to eq @person
        expect(rec.recommended_at).to eq Time.zone.today
        expect(rec.recommendation?).to be true

        # the rec is added to the table:
        within "#admin_person_cards_table" do
          expect(page).to have_selector "#card_#{rec.id}"
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
      expect(person.last_recommendations_at).to be_within(5.seconds).of(Time.zone.now)
    end

    example "clicking 'Done' without adding a recommendation note to the user" do
      visit_path
      expect { complete_card_recs_form.submit }.to_not change { account.recommendation_notes.count }
    end

    # TODO extract to a Trailblazer operation called Recommendation::Create
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

      new_note = account.recommendation_notes.order(created_at: :asc).last
      expect(new_note.content).to eq note_content
    end

    # TODO extract to a Trailblazer operation called Recommendation::Create
    example "recommendation note with trailing whitespace" do
      visit_path
      note_content = "  I like to leave notes.   "
      complete_card_recs_form.add_rec_note(note_content)
      complete_card_recs_form.submit

      new_note = account.recommendation_notes.order(created_at: :asc).last
      expect(new_note.content).to eq note_content.strip
    end

    # TODO extract to a Trailblazer operation called Recommendation::Create
    example "recommendation note that's only whitespace" do
      visit_path
      complete_card_recs_form.add_rec_note("     \n \n \t\ \t ")
      expect do
        complete_card_recs_form.submit
      end.to_not change { account.recommendation_notes.count }
    end
  end
end
