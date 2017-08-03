require 'rails_helper'

RSpec.describe 'admin - recommendation requests' do
  include_context 'logged in as admin'

  example 'index page' do
    with_no_req = create_account(:eligible)
    with_resolved_req = create_account(:eligible)
    solo_with_req = create_account(:eligible)
    couples_with_owner_req = create_account(:couples, :eligible)
    couples_with_comp_req = create_account(:couples, :eligible)
    couples_with_two_reqs = create_account(:couples, :eligible)

    create_recommendation_request('owner', with_resolved_req)
    complete_recs(with_resolved_req.owner)
    create_recommendation_request('owner', solo_with_req)
    create_recommendation_request('owner', couples_with_owner_req)
    create_recommendation_request('companion', couples_with_comp_req)
    create_recommendation_request('both', couples_with_two_reqs)

    visit admin_recommendation_requests_path

    expect(page).to have_content solo_with_req.email
    expect(page).to have_content couples_with_owner_req.email
    expect(page).to have_content couples_with_comp_req.email
    expect(page).to have_content couples_with_two_reqs.email
    expect(page).to have_no_content with_no_req.email
    expect(page).to have_no_content with_resolved_req.email
  end
end
