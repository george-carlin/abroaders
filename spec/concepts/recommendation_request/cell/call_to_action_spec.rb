require 'cells_helper'

RSpec.describe RecommendationRequest::Cell::CallToAction do
  controller ApplicationController

  include_context 'recommendation alert cell'

  let(:header) { 'Want to Earn More Rewards Points?' }

  let(:btn_text) { 'Request new card recommendations' }

  context 'solo account' do
    let(:account) { create(:account, :eligible, :onboarded) }
    let(:person)  { account.owner }

    example 'with unresolved recs' do
      create_rec(person: person)
      is_invalid
    end

    example 'with an unresolved request' do
      create_rec_request('owner', account)
      is_invalid
    end

    example 'with ineligible person' do
      person.update!(eligible: false)
      account.reload
      is_invalid
    end

    example 'who can make a request' do
      rendered = show(account)
      expect(rendered).to have_content header
      expect(rendered).to have_link btn_text
    end
  end

  context 'couples account' do
    # type select is initially hidden, and will be shown by JS. But this is a
    # cell spec and we don't care about the JS
    def have_type_select
      options = [owner.first_name, companion.first_name, 'Both of us']
      have_select(:person_type, options: options, visible: false)
    end

    let(:account) { create(:account, :couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }
    let(:people) { account.people }

    example 'with no eligible people' do
      people.each { |p| p.update!(eligible: false) }
      is_invalid
    end

    context 'one eligible' do
      # companion is ineligible, owner can request
      before { companion.update!(eligible: false) }

      example 'has unresolved request' do
        create_rec_request('owner', account)
        is_invalid
      end

      example 'has unresolved recs' do
        create_rec(person: owner)
        is_invalid
      end

      example 'can request' do
        rendered = show(account.reload)
        expect(rendered).to have_content header
        expect(rendered).to have_link btn_text
        expect(rendered).not_to have_type_select
      end
    end

    context 'both eligible' do
      example 'both can request' do
        rendered = show(account)
        expect(rendered).to have_content header
        expect(rendered).to have_link btn_text
        expect(rendered).to have_type_select
      end

      example 'owner has unresolved recs' do
        create_rec(person: owner)
        is_invalid
      end

      example 'companion has unresolved recs' do
        create_rec(person: companion)
        is_invalid
      end

      example 'both have unresolved recs' do
        create_rec(person: owner)
        create_rec(person: companion)
        is_invalid
      end

      example 'owner has unresolved request' do
        create_rec_request('owner', account)
        is_invalid
      end

      example 'companion has unresolved request' do
        create_rec_request('companion', account)
        is_invalid
      end

      example 'both have unresolved requests' do
        create_rec_request('both', account)
        account.reload
        is_invalid
      end

      example 'both can request a rec' do
        # has existing recs/reqs, but all are resolved
        create_rec_request('both', account)
        o_rec = create_rec(person: owner)
        c_rec = create_rec(person: companion)
        complete_recs(account)
        decline_rec(c_rec)
        o_rec.update!(applied_on: Date.today)
        rendered = show(account)
        expect(rendered).to have_link btn_text
        expect(rendered).to have_type_select
      end
    end
  end
end
