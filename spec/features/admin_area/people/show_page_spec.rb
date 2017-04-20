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

  let(:account) { @account }
  let(:person)  { @person }

  let(:complete_recs_form_selector) { '#complete_card_recommendations' }

  it 'has the correct title' do
    visit_path
    expect(page).to have_title full_title(person.first_name)
  end

  describe 'the card recommendation form', :js do
    before { visit_path }

    let(:offer) { @offers[3] }
    let(:offer_selector) { "#admin_recommend_offer_#{offer.id}" }

    example 'confirmation when clicking "recommend"' do
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

    example "recommending an offer" do
      expect do
        within offer_selector do
          click_button 'Recommend'
          click_button 'Confirm'
        end

        expect(page).to have_content 'Recommended!'
      end.to change { person.card_recommendations.count }.by(1)

      rec = person.card_recommendations.last

      expect(rec.recommended_by).to eq admin

      # the rec is added to the table:
      within '#admin_person_card_recommendations_table' do
        expect(page).to have_selector "#card_recommendation_#{rec.id}"
      end
    end
  end

  example 'marking recommendations as complete' do
    create_rec_request('owner', account)
    raise unless account.unresolved_recommendation_requests.count == 1 # sanity check
    visit_path
    expect do
      click_button 'Done'
      account.reload
    end.to \
      change { account.notifications.count }.by(1).and \
        change { account.unseen_notifications_count }.by(1).and \
          change { account.unresolved_recommendation_requests.count }.by(-1)
    # .and send_email.to(account.email).with_subject("Action Needed: Card Recommendations Ready")

    new_notification = account.notifications.order(created_at: :asc).last

    # it sends a notification to the user:
    expect(new_notification).to be_a(Notifications::NewRecommendations)
    expect(new_notification.record).to eq person
  end

  example 'deleting a recommendation', :js do
    rec = create_card_recommendation(person: person)
    visit_path

    within "#card_recommendation_#{rec.id}" do
      click_link 'Del'
    end

    expect(page).to have_no_selector "#card_recommendation_#{rec.id}"
    expect(Card.recommended.exists?(id: rec.id)).to be false
  end
end
