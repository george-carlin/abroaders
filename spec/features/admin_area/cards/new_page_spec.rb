require 'rails_helper'

module AdminArea
  RSpec.describe 'new card page' do
    include_context 'logged in as admin'

    let(:account) { create(:account, :onboarded) }
    let(:person)  { account.owner }
    let!(:product) { create(:card_product) }

    before { visit new_admin_person_card_path(person) }

    example 'creating a card' do
      expect(page).to have_field :card_product_id
      expect(page).to have_field :card_opened_at_1i
      expect(page).to have_field :card_opened_at_2i
      expect(page).to have_field :card_closed

      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)

      expect(current_path).to eq admin_person_path(person)
    end

    example 'invalid card creation', :js do
      check :card_closed
      # closed before opened:
      select (Date.today.year - 1).to_s, from: :card_closed_at_1i
      expect do
        click_button 'Save'
      end.not_to change { person.cards.count }

      # still shows form, including with the 'closed' inputs visible:
      expect(page).to have_field :card_product_id
      expect(page).to have_field :card_opened_at_1i
      expect(page).to have_field :card_opened_at_2i
      expect(page).to have_field :card_closed, checked: true
      expect(page).to have_field :card_closed_at_1i
      expect(page).to have_field :card_closed_at_2i
    end
  end
end
