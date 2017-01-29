require 'rails_helper'

RSpec.describe 'new card page' do
  include_context 'logged in'

  before do
    @products = create_list(:card_product, 3)
    @products.last.update!(shown_on_survey: false)
  end

  it 'lists all products' do
    # show all products, even if they're hidden on the onboarding survey
    @products.each do |card_product|
    end
  end

  describe 'adding an open card' do
  end
end
