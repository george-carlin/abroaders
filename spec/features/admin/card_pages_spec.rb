require "rails_helper"

describe "admin pages" do
  subject { page }

  describe "cards index page" do

    include_context "logged in as admin"

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

      describe "clicking the checkbox", js: true do
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

      describe "clicking the checkbox", js: true do
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
end
