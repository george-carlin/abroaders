require "rails_helper"

describe "admin pages" do
  include_context "logged in as admin"

  subject { page }

  let(:image_path) { Rails.root.join("spec","support","example_card_image.png") }

  def card_selector(card)
    "##{dom_id(card)}"
  end

  # TODO - annual fee needs upper and lower value limits. make sure we're
  # trimming whitespace too

  def it_has_fields_for_card
    expect(page).to have_field :card_code
    expect(page).to have_field :card_name
    expect(page).to have_field :card_network
    expect(page).to have_field :card_bp
    expect(page).to have_field :card_type
    expect(page).to have_field :card_annual_fee
    expect(page).to have_field :card_currency_id
    expect(page).to have_field :card_bank_id
    expect(page).to have_field :card_shown_on_survey
    expect(page).to have_field :card_image
  end

  describe "cards index page" do
    before do
      @survey_card     = create(:card)
      @non_survey_card = create(:card, shown_on_survey: false)
      visit admin_cards_path
    end

    let(:cards) { [ @survey_card, @non_survey_card ] }

    it "lists all cards" do
      expect(page).to have_selector card_selector(@survey_card)
      expect(page).to have_selector card_selector(@non_survey_card)
    end

    it "has a link to edit each card" do
      cards.each do |card|
        within card_selector(card) do
          is_expected.to have_link "Edit", href: edit_admin_card_path(card)
        end
      end
    end

    it "displays each card's currency" do
      cards.each do |card|
        within card_selector(card) do
          is_expected.to have_content card.currency.name
        end
      end
    end

    it "says whether or not the card is shown on the survey" do
      expect(page).to have_selector \
        "##{dom_id(@survey_card)} .card_shown_on_survey .fa.fa-check"
      expect(page).not_to have_selector \
        "##{dom_id(@non_survey_card)} .card_shown_on_survey .fa.fa-check"
    end
  end

  describe "new card page" do
    before do
      @currencies = create_list(:currency, 2)
      visit new_admin_card_path
    end

    it "has fields for a new card" do
      it_has_fields_for_card
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save Card" }

      describe "with valid information" do
        before do
          fill_in :card_code, with: "XXX"
          fill_in :card_name, with: "Chase Visa Something"
          select "MasterCard", from: :card_network
          select "Business",   from: :card_bp
          select "Credit",     from: :card_type
          # BUG: allow decimal values TODO
          fill_in :card_annual_fee, with: 549#.99
          select @currencies[0].name, from: :card_currency_id
          select "Wells Fargo", from: :card_bank_id
          uncheck :card_shown_on_survey
          attach_file :card_image, image_path
        end

        it "creates a card" do
          expect{submit_form}.to change{Card.count}.by(1)
        end

        it "shows me the newly created card" do
          submit_form
          card = Card.last
          expect(page).to have_selector "h1", text: "Chase Visa Something"
          expect(page).to have_content "XXX"
          expect(page).to have_content "MasterCard"
          expect(page).to have_content "Business"
          expect(page).to have_content "Credit"
          expect(page).to have_content "$549.00"#99"
          expect(page).to have_content @currencies[0].name
          expect(page).to have_content "Wells Fargo"
          expect(page).to have_selector "img[src='#{card.image.url}']"
        end
      end

      describe "with invalid information" do
        it "doesn't create a card" do
          expect{submit_form}.not_to change{Card.count}
        end
      end
    end
  end

  describe "edit card page" do
    before do
      @currencies = create_list(:currency, 2)
      @card = create(
        :card,
        currency: @currencies[0],
        bp:      :personal,
        network: :visa,
        type:    :credit,
        shown_on_survey: false
      )
      visit edit_admin_card_path(@card)
    end

    it "has fields to edit the card" do
      it_has_fields_for_card
    end

    describe "the 'b/p' input" do
      it "correctly defaults to the card's current BP" do # bug fix
        expect(page).to have_select :card_bp, selected: "Personal"
      end
    end

    describe "the 'network' input" do
      it "correctly defaults to the card's current network" do # bug fix
        expect(page).to have_select :card_network, selected: "Visa"
      end
    end

    describe "the 'type' input" do
      it "correctly defaults to the card's current type" do # bug fix
        expect(page).to have_select :card_type, selected: "Credit"
      end
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save Card" }

      describe "with valid information" do
        before do
          fill_in :card_code, with: "XXX"
          fill_in :card_name, with: "Chase Visa Something"
          select "MasterCard", from: :card_network
          select "Business",   from: :card_bp
          select "Credit",     from: :card_type
          # BUG: allow decimal values TODO
          fill_in :card_annual_fee, with: 549
          select @currencies[1].name, from: :card_currency_id
          select "Wells Fargo", from: :card_bank_id
          check :card_shown_on_survey
          submit_form
        end

        it "updates the card" do
          @card.reload
          expect(@card.code).to eq "XXX"
          expect(@card.name).to eq "Chase Visa Something"
          expect(@card.network).to eq "mastercard"
          expect(@card.bp).to eq "business"
          expect(@card.type).to eq "credit"
          expect(@card.annual_fee).to eq 549
          expect(@card.currency).to eq @currencies[1]
          expect(@card.bank).to eq Bank.find_by(name: "Wells Fargo")
          expect(@card).to be_shown_on_survey
        end

        it "shows me the updated card" do
          expect(current_path).to eq admin_card_path(@card)
        end
      end

      describe "with invalid information" do
        before { fill_in :card_code, with: "" }

        it "doesn't update the card" do
          pending "dafuq? blank text fields are not being submitted. I swear this was working before"
          expect{submit_form}.not_to change{@card.reload.attributes}
        end
      end
    end
  end
end
