require 'rails_helper'

RSpec.describe 'contact us page' do
  example 'when not logged in' do
    visit contact_us_path
    expect(page).to have_content 'Hey there'
    expect(page).to have_link 'Schedule a call with us'
  end

  example 'when logged in' do
    account = create(:person, first_name: 'George').account
    login_as_account(account)
    visit contact_us_path
    expect(page).to have_content 'Hey, George'
    expect(page).to have_link 'Schedule a call with us'
  end
end
