require "rails_helper"

describe "admin pages" do
  include_context "logged in as admin"

  subject { page }

  describe "cards index page" do
    before do
      @active_card   = create(:active_card)
      @inactive_card = create(:inactive_card)
      visit admin_cards_path
    end

    let(:cards) { [ @active_card, @inactive_card ] }

    it "lists all cards" do
      is_expected.to have_selector card_selector(@active_card)
      is_expected.to have_selector card_selector(@inactive_card)
    end

    it "displays each card's currency" do
      within card_selector(@active_card) do
        is_expected.to have_content @active_card.currency.name
      end
      within card_selector(@active_card) do
        is_expected.to have_content @active_card.currency.name
      end
    end

    describe "an active card" do
      it "has a checked checkbox and the text 'active'" do
        within card_selector(@active_card) do
          is_expected.to have_selector ".active-status", text: "Active"
          expect(find("input[type='checkbox']")).to be_checked
        end
      end

      describe "clicking the checkbox", :js do
        before do
          within card_selector(@active_card) do
            find("input[type=checkbox]").click
          end
        end

        it "saves the card as inactive" do
          wait_for_ajax
          expect(@active_card.reload).to be_inactive
        end

        it "updates the display" do
          within card_selector(@active_card) do
            is_expected.to have_selector ".active-status", text: "Inactive"
          end
        end
      end
    end

    describe "an inactive card" do
      it "has a checked checkbox and the text 'inactive'" do
        within card_selector(@inactive_card) do
          is_expected.to have_selector ".active-status", text: "Inactive"
          expect(find("input[type='checkbox']")).not_to be_checked
        end
      end

      describe "clicking the checkbox", :js do
        before do
          within card_selector(@inactive_card) do
            find("input[type=checkbox]").click
          end
        end

        it "saves the card as active" do
          wait_for_ajax
          expect(@inactive_card.reload).to be_active
        end

        it "updates the display" do
          within card_selector(@inactive_card) do
            is_expected.to have_selector ".active-status", text: "Active"
          end
        end
      end
    end


    def card_selector(card)
      "##{dom_id(card)}"
    end
  end

  describe "new card page" do
    before do
      @currencies = create_list(:currency, 2)
      visit new_admin_card_path
    end

    it "has fields for a new card" do
      expect(page).to have_field :card_code
      expect(page).to have_field :card_name
      expect(page).to have_field :card_network
      expect(page).to have_field :card_bp
      expect(page).to have_field :card_type
      expect(page).to have_field :card_annual_fee
      expect(page).to have_field :card_currency_id
      expect(page).to have_field :card_bank_id
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save Card" }

      describe "with valid information" do
        before do
          fill_in :card_code, with: "XXX"
          fill_in :card_name, with: "Chase Visa Something"
          select "Mastercard", from: :card_network
          select "Business",   from: :card_bp
          select "Credit",     from: :card_type
          fill_in :card_annual_fee, with: 549.99
          select @currencies[0].name, from: :card_currency_id
          select "Wells Fargo", from: :card_bank_id
        end

        it "creates a card" do
          expect{submit_form}.to change{Card.count}.by(1)
        end
      end

      describe "with invalid information" do
        it "doesn't create a card" do
          expect{submit_form}.not_to change{Card.count}
        end
      end
    end
  end
end
