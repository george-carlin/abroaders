require 'rails_helper'

module AdminArea
  RSpec.describe 'show person page', :manual_clean do
    include_context 'logged in as admin'

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
      @person = create(:person, :eligible)
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

    let(:complete_recs_form_selector) { '#complete_card_recommendations' }

    def click_complete_recs_button
      within complete_recs_form_selector do
        click_button 'Done'
      end
    end

    pending do
      expect(page).to have_title full_title(@person.first_name)
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
      let(:offer_selector) { "#admin_recommend_offer_#{offer.id}" }

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

      # TODO extract to a Trailblazer operation called CardRecommendation::Create
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

    example "marking recommendations as complete" do
      visit_path
      expect do
        click_complete_recs_button
        account.reload
      end.to \
        change { account.notifications.count }.by(1).and \
          change { account.unseen_notifications_count }.by(1)
      # .and send_email.to(account.email).with_subject("Action Needed: Card Recommendations Ready")

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
      expect { click_complete_recs_button }.to_not change { account.recommendation_notes.count }
    end

    # TODO extract to a Trailblazer operation called CardRecommendation::Create
    example "sending a recommendation note to the user" do
      visit_path
      expect(page).to have_field :recommendation_note

      note_content = "I like to leave notes."
      fill_in :recommendation_note, with: note_content

      # it sends the note to the user:
      expect do
        click_complete_recs_button
      end.to \
        change { account.recommendation_notes.count }.by(1)
      # .and send_email.to(account.email).with_subject("Action Needed: Card Recommendations Ready")

      new_note = account.recommendation_notes.order(created_at: :asc).last
      expect(new_note.content).to eq note_content
    end

    # TODO extract to a Trailblazer operation called CardRecommendation::Create
    example "recommendation note with trailing whitespace" do
      visit_path
      note_content = "  I like to leave notes.   "
      fill_in :recommendation_note, with: note_content
      click_complete_recs_button

      new_note = account.recommendation_notes.order(created_at: :asc).last
      expect(new_note.content).to eq note_content.strip
    end

    # TODO extract to a Trailblazer operation called CardRecommendation::Create
    example "recommendation note that's only whitespace" do
      visit_path
      fill_in :recommendation_note, with: "     \n \n \t\ \t "
      expect do
        click_complete_recs_button
      end.to_not change { account.recommendation_notes.count }
    end
  end
end
