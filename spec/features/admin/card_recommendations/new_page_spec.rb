require "rails_helper"

describe "admin section" do
  include_context "logged in as admin"
  subject { page }

  describe "person recommend card page" do
    let(:chase)   { Bank.find_by(name: "Chase")   }
    let(:us_bank) { Bank.find_by(name: "US Bank") }

    let(:aw_email) { "totallyawesomedude@example.com" }

    before do
      @currencies = create_list(:currency, 4)
      curr0, curr1, curr2, curr3 = @currencies;

      @cards = [
        @chase_b = create(:card, :business, bank_id: chase.id,   currency: curr0),
        @chase_p = create(:card, :personal, bank_id: chase.id,   currency: curr1),
        @usb_b =   create(:card, :business, bank_id: us_bank.id, currency: curr2),
        @usb_p =   create(:card, :personal, bank_id: us_bank.id, currency: curr3),
      ]

      @offers = [
        create(:offer, card: @chase_b),
        create(:offer, card: @chase_b),
        create(:offer, card: @chase_p),
        create(:offer, card: @usb_b),
        create(:offer, card: @usb_p)
      ]
      @dead_offer = create(:dead_offer, card: @chase_b)

      # Make the account created_at stamp different from the person's:
      @account = create(:account, created_at: 4.days.ago)
      @person  = @account.main_passenger

      @person.eligible_to_apply! if eligible
      if onboarded
        @person.create_spending_info!(
          credit_score: 678,
          has_business: :with_ein,
          business_spending_usd: 1500
        )
        @person.update_attributes!(
          onboarded_cards: true,
          onboarded_balances: true,
          award_wallet_email: aw_email,
        )
        @person.ready_to_apply! if ready_to_apply
      end

      if existing_notes
        existing_notes.times do
          create(:recommendation_note, account: account)
        end
      end

      extra_setup
      visit new_admin_person_card_recommendation_path(@person)

      if new_note
        fill_in "recommendation_note", with: new_note
      end

    end

    let(:account) { @account }
    let(:person)  { @person }
    let(:eligible) { true }
    let(:onboarded) { true }
    let(:ready_to_apply) { true }
    let(:extra_setup) { nil }
    let(:new_note) { nil }
    let(:existing_notes) { nil }

    def have_recommendable_card(card)
      have_selector recommendable_card_selector(card)
    end

    def recommendable_card_selector(card)
      "##{dom_id(card, :admin_recommend)}"
    end

    def offer_selector(offer)
      "#" << dom_id(offer, :admin_recommend)
    end

    let(:name) { @person.first_name }

    it { is_expected.to have_title full_title "#{name} - Recommend Card" }

    context "for a person who has not completed the onboarding survey" do
      let(:onboarded) { false }
      it "redirects back to the person show page" do
        expect(current_path).to eq admin_person_path(@person)
      end
    end

    context "for a person who has completed the onboarding survey" do
      let(:onboarded) { true }
      context "but is not ready to apply" do
        let(:ready_to_apply) { false }
        it "redirects back to the person show page" do
          expect(current_path).to eq admin_person_path(@person)
        end
      end
    end

    it "shows the date on which the account was created" do
      is_expected.to have_content @account.created_at.strftime("%D")
    end

    context "when the person" do
      context "has added an award wallet email" do
        it "displays it" do
          is_expected.to have_content "Award Wallet email"
          is_expected.to have_content aw_email
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

          it "lists them" do
            within "#admin_person_cards_from_survey" do
              is_expected.to have_selector "##{dom_id(@opened_acc)}"
              is_expected.to have_selector "##{dom_id(@closed_acc)}"
            end
            within "##{dom_id(@opened_acc)}" do
              is_expected.to have_content "Open"
            end
            within "##{dom_id(@closed_acc)}" do
              is_expected.to have_content "Closed"
            end
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

          it "lists them" do
            within "#admin_person_card_recommendations" do
              is_expected.to have_selector "##{dom_id(@new_rec)}"
              is_expected.to have_selector "##{dom_id(@clicked_rec)}"
              is_expected.to have_selector "##{dom_id(@declined_rec)}"
            end
          end

          it "shows each card's status" do
            within "##{dom_id(@new_rec)}" do
              is_expected.to have_selector ".card_account_status", text: "Recommended"
            end
            within "##{dom_id(@clicked_rec)}" do
              is_expected.to have_selector ".card_account_status", text: "Recommended"
            end
            within "##{dom_id(@declined_rec)}" do
              is_expected.to have_selector ".card_account_status", text: "Declined"
            end
          end

          it "shows the recommended/applied/opened/closed dates for each card" do
            within "##{dom_id(@new_rec)}" do
              is_expected.to have_selector ".card_account_recommended_at", text: "01/01/15"
              is_expected.to have_selector ".card_account_clicked_at",     text: "-"
              is_expected.to have_selector ".card_account_applied_at",     text: "-"
            end
            within "##{dom_id(@clicked_rec)}" do
              is_expected.to have_selector ".card_account_recommended_at", text: "03/01/15"
              is_expected.to have_selector ".card_account_clicked_at",     text: "10/01/15"
              is_expected.to have_selector ".card_account_applied_at",     text: "-"
            end
            within "##{dom_id(@declined_rec)}" do
              is_expected.to have_selector ".card_account_recommended_at", text: "10/01/15"
              is_expected.to have_selector ".card_account_clicked_at",     text: "-"
              is_expected.to have_selector ".card_account_declined_at",    text: "12/01/15"
            end
          end

          context "when a recommendation has been declined" do
            it "shows the decline reason in a tooltip" do
              within "##{dom_id(@declined_rec)}" do
                is_expected.to have_selector "a[data-toggle='tooltip']"
                tooltip = find("a[data-toggle='tooltip']")
                expect(tooltip["title"]).to eq "because"
              end
            end
          end
        end
      end
    end

    it "displays the person's info from the onboarding survey" do
      is_expected.to have_content "Credit score: 678"
      is_expected.to have_content "Will apply for loan in next 6 months: No"
      is_expected.to have_content "Business spending: $1,500.00"
      is_expected.to have_content "(Has EIN)"
    end

    it "has a form to recommend a new card" do
      is_expected.to have_selector ".admin-card-recommendation-table"
    end

    describe "the card recommendation form" do
      it "has an option to recommend each offer" do
        within ".admin-card-recommendation-table" do
          @offers.each do |offer|
            is_expected.to have_selector offer_selector(offer)
            is_expected.to have_selector "#recommend_#{dom_id(offer)}_btn"
          end
        end
      end

      it "doesn't have links to recommend dead offers" do
        within ".admin-card-recommendation-table" do
          is_expected.to have_no_selector offer_selector(@dead_offer)
          is_expected.to have_no_selector "#recommend_#{dom_id(@dead_offer)}_btn"
        end
      end

      it "has a link to each offer" do
        @offers.each do |offer|
          within offer_selector(offer) do
            is_expected.to have_link "Link", offer.link
          end
        end
      end

      specify "offer links open in a new tab" do
        @offers.each do |offer|
          within offer_selector(offer) do
            expect(find("a[href='#{offer.link}']")[:target]).to eq "_blank"
          end
        end
      end

      describe "filters", :js do
        def should_have_recommendable_cards(*cards)
          cards.each { |card| should have_recommendable_card(card) }
        end

        def should_not_have_recommendable_cards(*cards)
          cards.each { |card| should_not have_recommendable_card(card) }
        end

        let(:business_filter) { :card_bp_filter_business }
        let(:personal_filter) { :card_bp_filter_personal }
        let(:chase_filter)    { :"card_bank_filter_#{chase.id}" }
        let(:us_bank_filter)  { :"card_bank_filter_#{us_bank.id}" }

        describe "the cards" do
          specify "can be filtered by b/p" do
            uncheck business_filter
            should_have_recommendable_cards(@chase_p, @usb_p)
            should_not_have_recommendable_cards(@chase_b, @usb_b)
            uncheck personal_filter
            should_not_have_recommendable_cards(*@cards)
            check business_filter
            should_have_recommendable_cards(@chase_b, @usb_b)
            should_not_have_recommendable_cards(@chase_p, @usb_p)
            check personal_filter
            should_have_recommendable_cards(*@cards)
          end

          specify "can be filtered by bank" do
            Bank.all.each do |bank|
              is_expected.to have_field :"card_bank_filter_#{bank.id}"
            end

            uncheck chase_filter
            should_have_recommendable_cards(@usb_b, @usb_p)
            should_not_have_recommendable_cards(@chase_b, @chase_p)
            uncheck us_bank_filter
            should_not_have_recommendable_cards(*@cards)
            check chase_filter
            should_have_recommendable_cards(@chase_b, @chase_p)
            should_not_have_recommendable_cards(@usb_b, @usb_p)
            check us_bank_filter
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
            uncheck :card_bank_filter_all
            should_not_have_recommendable_cards(*@cards)
            Bank.all.each do |bank|
              expect(find("#card_bank_filter_#{bank.id}")).not_to be_checked
            end
            check :card_bank_filter_all
            should_have_recommendable_cards(*@cards)
            Bank.all.each do |bank|
              expect(find("#card_bank_filter_#{bank.id}")).to be_checked
            end
          end

          it "is checked/unchecked automatically as I click other CBs" do
            uncheck chase_filter
            expect(find("#card_bank_filter_all")).not_to be_checked
            check chase_filter
            expect(find("#card_bank_filter_all")).to be_checked
          end
        end
      end # filters

      describe "clicking 'recommend' next to an offer", :js do
        let(:offer) { @offers[3] }
        before { find("#recommend_#{dom_id(offer)}_btn").click }
        let(:offer_tr) { "##{dom_id(offer, :admin_recommend)}" }

        it "shows confirm/cancel buttons" do
          within offer_tr do
            is_expected.to have_no_button "Recommend"
            is_expected.to have_button "Cancel"
            is_expected.to have_button "Confirm"
          end
        end

        describe "clicking 'Confirm'" do
          let(:confirm) do
            within offer_tr do
              click_button "Confirm"
            end
          end

          it "recommends that card to the person" do
            expect{confirm}.to change{CardAccount.recommendations.count}.by(1)
          end

          describe "the new recommendation" do
            before { confirm }

            let(:rec) { CardAccount.recommendations.last }

            it "has the correct offer, card, and person" do
              expect(rec.card).to eq offer.card
              expect(rec.offer).to eq offer
              expect(rec.person).to eq @person
            end

            it "has 'recommended at' set to the current date" do
              expect(rec.recommended_at).to eq Date.today
            end

            it "is a recommendation" do
              expect(rec.recommendation?).to be true
            end
          end
        end # clicking 'Confirm'

        describe "clicking 'Cancel'" do
          let(:cancel) do
            within offer_tr do
              click_button "Cancel"
            end
          end

          it "doesn't recommend the card to the person" do
            expect{cancel}.not_to change{CardAccount.count}
          end

          it "shows the 'recommend' button again" do
            cancel
            within offer_tr do
              is_expected.to have_button "Recommend"
              is_expected.to have_no_button "Confirm"
              is_expected.to have_no_button "Cancel"
            end
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
        expect{click_done}.to change{ApplicationMailer.deliveries.length}.by(1)
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

      it "has a text input for Recommendation Notes" do
        expect(page).to have_selector("input", "recommendation_note")
      end

      describe "User has no recommendation notes" do
        it "doesn't display the recommendation note panel" do
          expect(page).to have_no_content "Recommendation Notes"
        end
      end

      describe "User has recommendation notes" do
        let(:existing_notes) {3}
        let(:new_note) {"I like to leave notes."}
        it "displays the recommendation notes" do
          expect(page).to have_content("Recommendation Notes")
          account.recommendation_notes.each do |note|
            expect(page).to have_content note.created_at
            expect(page).to have_content note.content
          end
        end
        it "adds another recommendation note to account when clicking done" do
          expect do
            click_done
            account.recommendation_notes.reload
          end.to change{account.recommendation_notes.count}.by(1)
          expect(account.recommendation_notes.order(:created_at).last.content).to eq new_note
        end
      end


      describe "User has filled out the notes field" do
        let(:new_note) {"I like to leave notes."}
        it "adds a recommendation note to account when clicking done" do
          expect do
            click_done
            account.reload
          end.to change{account.recommendation_notes.count}.by(1)
          expect(account.recommendation_notes.order(:created_at).last.content).to eq new_note
        end
      end


      describe "User has not filled out the notes field" do
        it "doesn't add a recommendation note when clicking done" do
          expect{click_done}.to_not change{account.recommendation_notes.count}
        end
      end
    end

  end
end
