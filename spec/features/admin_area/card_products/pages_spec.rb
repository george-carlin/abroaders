require "rails_helper"

RSpec.describe "admin product pages" do
  include_context "logged in as admin"

  subject { page }

  let(:image_path) { Rails.root.join('spec', 'support', 'example_card_image.png') }

  def card_product_selector(product)
    "##{dom_id(product)}"
  end

  # TODO - annual fee needs upper and lower value limits. make sure we're
  # trimming whitespace too

  def it_has_fields_for_card_product
    expect(page).to have_field :card_product_code
    expect(page).to have_field :card_product_name
    expect(page).to have_field :card_product_network
    expect(page).to have_field :card_product_bp
    expect(page).to have_field :card_product_type
    expect(page).to have_field :card_product_annual_fee
    expect(page).to have_field :card_product_currency_id
    expect(page).to have_field :card_product_bank_id
    expect(page).to have_field :card_product_shown_on_survey
    expect(page).to have_field :card_product_image
  end

  describe 'index page' do
    before do
      @product        = create(:card_product)
      @hidden_product = create(:card_product, shown_on_survey: false)
      visit admin_card_products_path
    end

    let(:products) { [@product, @hidden_product] }

    it { is_expected.to have_title full_title('Card Products') }

    it 'lists info about each cards' do
      expect(page).to have_selector card_product_selector(@product)
      expect(page).to have_selector card_product_selector(@hidden_product)

      products.each do |product|
        within card_product_selector(product) do
          # it has a link to edit each card
          expect(page).to have_link "Edit", href: edit_admin_card_product_path(product)
          # it displays each card's currency
          expect(page).to have_content product.currency.name
        end
      end

      # says whether or not the card is shown on the survey
      expect(page).to have_selector \
        "##{dom_id(@product)} .card_shown_on_survey .fa.fa-check"
      expect(page).to have_no_selector \
        "##{dom_id(@hidden_product)} .card_shown_on_survey .fa.fa-check"
    end
  end

  describe 'new page' do
    let!(:banks) { create_list(:bank, 2) }
    before do
      @currencies = create_list(:currency, 2)
      visit new_admin_card_product_path
    end

    it "has fields for a new card" do
      it_has_fields_for_card_product
    end

    describe "the 'currency dropdown'" do
      it "has a 'no currency' option, which is selected by default" do
        expect(find_field(:card_product_currency_id)).to have_content('No currency')
      end
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save Card" }

      let(:currency)      { @currencies[0] }
      let(:currency_name) { currency.name }

      describe "with valid information" do
        before do
          fill_in :card_product_code, with: "XXX"
          fill_in :card_product_name, with: "Chase Visa Something"
          select "MasterCard", from: :card_product_network
          select 'Business',   from: :card_product_bp
          select "Credit",     from: :card_product_type
          # BUG: allow decimal values TODO
          fill_in :card_product_annual_fee, with: 549 # .99
          select currency_name, from: :card_product_currency_id
          select banks[1].name, from: :card_product_bank_id
          uncheck :card_product_shown_on_survey
          attach_file :card_product_image, image_path
        end

        let(:product) { CardProduct.last }

        it "shows me the newly created product" do
          expect { submit_form }.to change { CardProduct.count }.by(1)
          expect(page).to have_selector 'h1', text: "Chase Visa Something"
          expect(page).to have_content "XXX"
          expect(page).to have_content "MasterCard"
          expect(page).to have_content "business"
          expect(page).to have_content "Credit"
          expect(page).to have_content "$549.00" # 99"
          expect(page).to have_content currency_name
          expect(page).to have_content banks[1].name
          expect(page).to have_selector "img[src='#{product.image.url}']"
        end

        it "strips trailing whitespace from text inputs" do
          fill_in :card_product_code, with: "   ABC   "
          fill_in :card_product_name, with: "    something  "
          submit_form

          expect(product.code).to eq "ABC"
          expect(product.name).to eq "something"
        end

        context "and no currency" do
          let(:currency_name) { "No currency" }
          it "creates a product with no currency" do
            expect { submit_form }.to change { CardProduct.count }.by(1)
            expect(product.currency).to be_nil
          end
        end
      end

      describe "with invalid information" do
        it "doesn't create a product" do
          expect { submit_form }.not_to change { CardProduct.count }
        end
      end
    end
  end

  describe 'edit page' do
    let!(:banks) { create_list(:bank, 2) }
    before do
      @currencies = create_list(:currency, 2)
      @product = create(
        :card_product,
        currency: @currencies[0],
        bp:      :personal,
        network: :visa,
        type:    :credit,
        shown_on_survey: false,
        bank:    banks[0],
      )
      visit edit_admin_card_product_path(@product)
    end

    it "has fields to edit the product" do
      it_has_fields_for_card_product

      # with correct pre-filled dropdown (bug fix):
      expect(page).to have_select :card_product_bp, selected: "Personal"
      expect(page).to have_select :card_product_network, selected: "Visa"
      expect(page).to have_select :card_product_type, selected: "Credit"
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save Card" }

      describe "with valid information" do
        before do
          fill_in :card_product_code, with: "XXX"
          fill_in :card_product_name, with: "Chase Visa Something"
          select "MasterCard", from: :card_product_network
          select "Business",   from: :card_product_bp
          select "Credit",     from: :card_product_type
          # BUG: allow decimal values TODO
          fill_in :card_product_annual_fee, with: 549
          select @currencies[1].name, from: :card_product_currency_id
          select banks[1].name, from: :card_product_bank_id
          check :card_product_shown_on_survey
          submit_form
        end

        it 'updates the product and display it' do
          @product.reload
          expect(@product.code).to eq "XXX"
          expect(@product.name).to eq "Chase Visa Something"
          expect(@product.network).to eq "mastercard"
          expect(@product.bp).to eq "business"
          expect(@product.type).to eq "credit"
          expect(@product.annual_fee).to eq 549
          expect(@product.currency).to eq @currencies[1]
          expect(@product.bank).to eq banks[1]
          expect(@product).to be_shown_on_survey

          expect(current_path).to eq admin_card_product_path(@product)
        end
      end

      describe "with invalid information" do
        before { fill_in :card_product_code, with: "" }

        it "doesn't update the card" do
          expect { submit_form }.not_to change { @product.reload.attributes }
        end
      end
    end
  end
end
