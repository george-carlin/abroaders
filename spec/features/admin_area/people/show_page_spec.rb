require 'rails_helper'

RSpec.describe 'admin - show person page', :manual_clean do
  include_context 'logged in as admin'

  before(:all) do
    @chase   = create(:bank, name: "Chase")
    @us_bank = create(:bank, name: "US Bank")

    @currencies = []
    @currencies << create(:currency, alliance_name: 'OneWorld')
    @currencies << create(:currency, alliance_name: 'SkyTeam')
    @currencies << create(:currency, alliance_name: 'OneWorld')

    def create_product(bp, bank, currency)
      create(:card_product, bp, bank_id: bank.id, currency: currency)
    end

    @products = [
      @chase_b = create_product(:business, @chase,   @currencies[0]),
      @chase_p = create_product(:personal, @chase,   @currencies[1]),
      @usb_b   = create_product(:business, @us_bank, @currencies[2]),
    ]

    @offers = [
      create_offer(product: @chase_b),
      create_offer(product: @chase_b),
      create_offer(product: @chase_p),
      create_offer(product: @usb_b),
    ]
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

  it 'has the correct title' do
    visit_path
    expect(page).to have_title full_title(person.first_name)
  end

  describe 'the card recommendation form' do
    before { visit_path }

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

    example "recommending an offer", :js do
      within offer_selector do
        click_button 'Recommend'
        click_button 'Confirm'
      end

      wait_for_ajax

      expect(page).to have_content 'Recommended!'

      # the rec is added to the table:
      rec = Card.recommended.last
      within '#admin_person_cards_table' do
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
end
