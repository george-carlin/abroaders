# SURVEYTODO

#  describe "the card accounts survey" do
#    before do
#      create(:survey, account: account)
#      account.reload
#
#      @cards = [
#        @chase_b    = create(:card, :business, bank: :chase),
#        @chase_p    = create(:card, :personal, bank: :chase),
#        @citibank_b = create(:card, :business, bank: :citibank),
#        @citibank_p = create(:card, :personal, bank: :citibank),
#        @barclays_b = create(:card, :business, bank: :barclays),
#        @barclays_p = create(:card, :personal, bank: :barclays)
#      ]
#      visit survey_card_accounts_path
#    end
#
#    let(:submit_form) { click_button "Save" }
#
#    H = "h3"
#
#    def bank_div_selector(bank)
#      "##{bank}_cards"
#    end
#
#    def bank_bp_div_selector(bank, bp)
#      "##{bank}_#{bp}_cards"
#    end
#
#    def card_checkbox(card)
#      :"card_account_card_ids_#{card.id}"
#    end
#
#    it "lists cards grouped by bank, then B/P" do
#      is_expected.to have_selector H, text: "Chase Personal Cards"
#      is_expected.to have_selector bank_div_selector(:chase)
#      is_expected.to have_selector bank_bp_div_selector(:chase, :personal)
#
#      is_expected.to have_selector H, text: "Chase Business Cards"
#      is_expected.to have_selector bank_div_selector(:chase)
#      is_expected.to have_selector bank_bp_div_selector(:chase, :business)
#
#      is_expected.to have_selector H, text: "Citibank Personal Cards"
#      is_expected.to have_selector bank_div_selector(:citibank)
#      is_expected.to have_selector bank_bp_div_selector(:citibank, :personal)
#
#      is_expected.to have_selector H, text: "Citibank Business Cards"
#      is_expected.to have_selector bank_div_selector(:citibank)
#      is_expected.to have_selector bank_bp_div_selector(:citibank, :business)
#
#      is_expected.to have_selector H, text: "Barclays Personal Cards"
#      is_expected.to have_selector bank_div_selector(:barclays)
#      is_expected.to have_selector bank_bp_div_selector(:barclays, :personal)
#
#      is_expected.to have_selector H, text: "Barclays Business Cards"
#      is_expected.to have_selector bank_div_selector(:barclays)
#      is_expected.to have_selector bank_bp_div_selector(:barclays, :business)
#    end
#
#    it "has a checkbox for each card" do
#      @cards.each do |card|
#        is_expected.to have_field card_checkbox(card)
#      end
#    end
#
#    shared_examples "saves survey completion" do
#      it "records internally that I have completed the cards survey" do
#        expect(account.has_added_cards?).to be_falsey # Sanity check
#        submit_form
#        expect(account.reload.has_added_cards?).to be_truthy
#      end
#
#      it "takes me to the balances survey page" do
#        submit_form
#        expect(current_path).to eq survey_balances_path
#      end
#    end
#
#    describe "selecting some cards" do
#      before do
#        check card_checkbox(@chase_b)
#        check card_checkbox(@citibank_b)
#        check card_checkbox(@citibank_p)
#      end
#
#      describe "and clicking 'Save'" do
#        it "assigns the cards to my account" do
#          expect { submit_form }.to \
#              change{account.card_accounts.unknown.count}.by(3)
#          accounts = account.card_accounts
#          expect(accounts.map(&:card)).to match_array [
#            @chase_b, @citibank_p, @citibank_b
#          ]
#        end
#
#        include_examples "saves survey completion"
#      end
#    end
#
#
#    describe "submitting the form without selecting any cards" do
#      it "doesn't assign any cards to my account" do
#        expect { submit_form }.not_to change{CardAccount.count}
#      end
#
#      include_examples "saves survey completion"
#    end
#  end
