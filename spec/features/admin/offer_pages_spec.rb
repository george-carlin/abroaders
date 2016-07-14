require "rails_helper"

describe "admin section" do
  include_context "logged in as admin"
  subject { page }

  describe "offers pages" do
    describe "new page" do
      before do
        @card = create(
          :card,
          name:    "Sapphire Preferred",
          network: :visa,
          annual_fee_cents: 1500_00,
          bp:   :business,
          bank: Bank.find_by(name: "Chase")
        )

        visit new_admin_card_offer_path(@card)
      end

      let(:submit) { click_button t("admin.offers.submit") }

      it { is_expected.to have_title full_title("New Offer") }

      it "displays information about the card" do
        is_expected.to have_content "Chase"
        is_expected.to have_content "Sapphire Preferred"
        is_expected.to have_content "Visa"
        is_expected.to have_content "$1,500"
        is_expected.to have_content "business"
      end

      it "has fields for an offer" do
        is_expected.to have_field :offer_condition
        is_expected.to have_field :offer_points_awarded
        is_expected.to have_field :offer_spend
        is_expected.to have_field :offer_cost
        is_expected.to have_field :offer_days
        is_expected.to have_field :offer_link
        is_expected.to have_field :offer_notes
      end

      let(:approval)       { t("activerecord.attributes.offer.conditions.on_approval") }
      let(:first_purchase) { t("activerecord.attributes.offer.conditions.on_first_purchase") }
      let(:minimum_spend)  { t("activerecord.attributes.offer.conditions.on_minimum_spend") }

      let(:new_offer) { Offer.last }

      describe "the 'condition' dropdown" do
        it "has 'on minimum spend' selected by default" do
          selected_opt = find("#offer_condition option[selected]")
          expect(selected_opt.value).to eq "on_minimum_spend"
        end
      end

      describe "selecting 'on approval' condition'", :js do
        before { select approval, from: :offer_condition }
        it "hides the irrelevant inputs" do
          is_expected.not_to have_field :offer_spend
          is_expected.not_to have_field :offer_days
        end

        describe "and selecting 'minimum spend' again" do
          before { select minimum_spend, from: :offer_condition }
          it "shows the inputs again" do
            is_expected.to have_field :offer_spend
            is_expected.to have_field :offer_days
          end
        end

        describe "and submitting the form with valid info" do
          before do
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
          end

          it "creates an offer" do
            expect{submit}.to change{Offer.count}.by 1
            expect(new_offer.condition).to eq "on_approval"
            expect(new_offer.card).to eq @card
            expect(new_offer.points_awarded).to eq 40_000
            expect(new_offer.link).to eq "http://something.com"
          end

          it "doesn't save any values for the irrelevant columns" do
            submit
            expect(new_offer.spend).to be_nil
            expect(new_offer.days).to be_nil
          end
        end

        describe "and submitting the form with invalid info" do
          before { submit }
          it "shows the form again with the correct fields hidden/shown" do
            is_expected.to have_field :offer_condition
            is_expected.to have_field :offer_points_awarded
            is_expected.not_to have_field :offer_spend
            is_expected.to have_field :offer_cost
            is_expected.not_to have_field :offer_days
            is_expected.to have_field :offer_link
            is_expected.to have_field :offer_notes
          end
        end
      end

      describe "selecting 'on first purchase' condition'", :js do
        before { select first_purchase, from: :offer_condition }
        it "hides the irrelevant inputs" do
          is_expected.not_to have_field :offer_spend
        end

        describe "and selecting 'minimum spend' again" do
          before { select minimum_spend, from: :offer_condition }
          it "shows the inputs again" do
            is_expected.to have_field :offer_spend
          end
        end

        describe "and submitting the form with valid info" do
          before do
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
            fill_in :offer_days, with: 120
          end

          it "creates an offer" do
            expect{submit}.to change{Offer.count}.by 1
            expect(new_offer.condition).to eq "on_first_purchase"
            expect(new_offer.card).to eq @card
            expect(new_offer.days).to eq 120
            expect(new_offer.points_awarded).to eq 40_000
            expect(new_offer.link).to eq "http://something.com"
          end

          it "doesn't save any values for the irrelevant columns" do
            submit
            expect(new_offer.spend).to be_nil
          end
        end

        describe "and submitting the form with invalid info" do
          before { submit }
          it "shows the form again with the correct fields hidden/shown" do
            is_expected.to have_field :offer_condition
            is_expected.to have_field :offer_points_awarded
            is_expected.not_to have_field :offer_spend
            is_expected.to have_field :offer_cost
            is_expected.to have_field :offer_days
            is_expected.to have_field :offer_link
            is_expected.to have_field :offer_notes
          end
        end
      end

      describe "submitting the form with valid information" do
        before do
          fill_in :offer_points_awarded, with: 40_000
          fill_in :offer_spend, with: 5000
          fill_in :offer_link, with: "http://something.com"
        end

        it "creates a new offer" do
          expect{submit}.to change{Offer.count}.by(1)
          expect(new_offer.condition).to eq "on_minimum_spend"
        end

        describe "the created offer" do
          before { submit }
          it "has the correct attributes" do
            expect(new_offer.card).to eq @card
            expect(new_offer.points_awarded).to eq 40_000
            expect(new_offer.spend).to eq 5_000
            expect(new_offer.link).to eq "http://something.com"
          end
        end

      end

      describe "submitting the form with invalid information" do
        before { submit }

        it "shows the form again with an error message" do
          expect(page).to have_selector "form#new_offer"
          expect(page).to have_error_message
        end

        specify "the error message talks about the 'offer'" do # bug fix
          within ".alert.alert-danger" do
            expect(page).to have_content "offer"
          end
        end
      end

      describe "the 'Link' input" do
        let(:input) { find("#offer_link") }
        it "is a text field" do # bug fix
          expect(input[:type]).to eq "text"
        end
      end
    end # new page

    describe "offers page" do

      let(:route) { admin_offers_path }

      before do
        @live_1 = create(:live_offer, last_reviewed_at: DateTime.yesterday)
        visit route
      end

      describe "when viewing offers" do
        it "shows offer details", :js => true do
          is_expected.to have_content @live_1.card.name
          expect(find("tr#offer_#{@live_1.id}").text).to include(@live_1.last_reviewed_at.strftime("%m/%d/%Y"))
        end
      end

    end # offers page

    describe "review page" do

      let(:route) { review_admin_offers_path }

      before do
        @live_1 = create(:live_offer)
        @live_2 = create(:live_offer, last_reviewed_at: DateTime.yesterday)
        @live_3 = create(:live_offer)
        @dead_1 = create(:dead_offer)
        visit route
      end

      describe "when page loads" do
        it "shows only live offers" do
          expect(page).to have_selector( ".offer", count: Offer.live.count)
        end
      end

      describe "when viewing non-reviewed offers" do
        it "shows offer details" do
          is_expected.to have_content @live_1.card.name
          is_expected.to have_content @live_1.card.bp
          expect(find("tr#offer_#{@live_1.id}").text).to include('never')
          is_expected.to have_link('Link', href: @live_1.link)
          is_expected.to have_button "kill_offer_#{ @live_1.id }_btn"
          is_expected.to have_button "verify_offer_#{ @live_1.id }_btn"
        end
      end

      describe "when viewing reviewed offers" do
        it "shows reviewed date" do
          expect(find("tr#offer_#{@live_2.id}").text).to include(@live_2.last_reviewed_at.to_date.strftime("%m/%d/%Y"))
        end
      end

      describe "when pressing Verify" do
        it "updates selected last_reviewed_at datetime", :js => true do
          click_button("verify_offer_#{ @live_1.id }_btn")
          wait_for_ajax
          @live_1.reload
          expect(@live_1.last_reviewed_at).to be_within(2.seconds).of(Time.now)
          expect(find("#reviewed_#{@live_1.id}").text).to include(Time.now.strftime("%m/%d/%Y"))
        end
      end

      describe "when pressing Verify" do
        it "does not update other last_reviewed_at datetimes", :js => true do
          expect do
            click_button("verify_offer_#{ @live_1.id }_btn")
            wait_for_ajax
            @live_2.reload
            @dead_1.reload
          end.not_to change{ @live_2.last_reviewed_at }
        end
      end

      describe "pressing kill then cancel" do
        it "doesn't kill the offer", :js => true do
          expect do
            page.dismiss_confirm do
              click_button("kill_offer_#{ @live_1.id }_btn")
            end
          end.not_to change{Offer.live.count}
        end
      end

      describe "pressing Kill then confirm" do
        it "removes offer from the user display", :js => true do
          page.accept_confirm do
            find_button("kill_offer_#{ @live_1.id }_btn").click
          end
          expect(page).to have_selector( ".offer", count: Offer.live.count)
        end
      end

      describe "pressing Kill then confirm", :js => true do
        it "changes offer live value to false" do
          page.accept_confirm do
            find_button("kill_offer_#{ @live_2.id }_btn").click
          end
          wait_for_ajax
          @live_2.reload
          expect(@live_2.live?).to be false
          expect(@live_2.killed_at).to be_within(2.seconds).of(Time.now)
        end
      end

      describe "when killing offers" do
        it "doesnt't delete offers from the database", :js => true do
          page.accept_confirm do
            find_button("kill_offer_#{ @live_3.id }_btn").click
          end
          expect(@live_3).to_not be_nil
        end
      end

    end # review page

    describe "show page" do
      let(:offer)  { create(:offer, notes: 'aisjhdoifajsdf') }
      let(:card)   { offer.card }
      before { visit route }

      let(:route) { admin_card_offer_path(card, offer) }

      describe "when accessing the shallow path" do
        let(:route) { admin_offer_path(offer) }
        it "redirects to the nested path" do
          expect(current_path).to eq admin_card_offer_path(card, offer)
        end
      end

      it "displays information about the offer and card" do
        is_expected.to have_content card.name
        is_expected.to have_content offer.notes
      end
    end # show page


    describe "edit page" do
      let(:offer) { create(:offer) }
      let(:card)  { offer.card }
      before { visit route }

      let(:route) { edit_admin_card_offer_path(card, offer) }

      describe "when accessing the shallow path" do
        let(:route) { edit_admin_offer_path(offer) }
        it "redirects to the nested path" do
          expect(current_path).to eq edit_admin_card_offer_path(card, offer)
        end
      end

      it "displays information about the card" do
        is_expected.to have_content card.name
      end
    end
  end
end
