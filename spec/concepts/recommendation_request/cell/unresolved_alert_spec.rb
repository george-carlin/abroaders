require 'cells_helper'

RSpec.describe RecommendationRequest::Cell::UnresolvedAlert do
  include_context 'recommendation alert cell'

  context 'solo account' do
    let(:account) { create(:account, :eligible, :onboarded) }
    let(:person)  { account.owner }

    example 'with unresolved req' do
      create_rec_request('owner', account)
      # mark the first one as resolved
      run!(AdminArea::CardRecommendations::Complete, person_id: person.id)
      create_rec_request('owner', account)
      text = 'Abroaders is Working on Your Card Recommendations'
      expect(show(account)).to have_content text
    end

    example 'with no reqs' do
      is_invalid
    end

    example 'with resolved reqs' do
      create_rec_request('owner', account)
      run!(AdminArea::CardRecommendations::Complete, person_id: person.id)
      is_invalid
    end

    example 'with unresolved recs' do
      create_rec_request('owner', account)
      create_rec(person: person)
      # unresolved recs override unresolved requests, so this alert
      # should not be shown
      is_invalid
    end
  end

  context 'couples account' do
    let(:account) { create(:account, :couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }
    let(:people) { account.people }

    def have_alert_for(*people_with_recs)
      names = people_with_recs.map(&:first_name).join(' and ')
      have_content("Abroaders is Working on Card Recommendations for #{names}").and(
        have_content('They should be ready in 1-2 business days'),
      )
    end

    # Don't bother testing permutations involving ineligible people. Ineligible
    # people shouldn't have rec requests in the first place so the logic
    # that checks for an unresolved request is by extension checking that
    # at least one person is eligible.

    example 'no reqs' do
      is_invalid
    end

    example 'all reqs are resolved' do
      create_rec_request('both', account)
      run!(AdminArea::CardRecommendations::Complete, person_id: owner.id)
      is_invalid
    end

    example 'unresolved reqs, and unresolved recs' do
      # unresolved recs override unresolved requests, so this alert
      # should not be shown
      create_rec_request('both', account)
      create_rec(person: owner)
      is_invalid
    end

    example 'unresolved reqs, resolved recs' do
      create_rec(person: owner).update!(applied_on: Date.today)
      create_rec_request('both', account)
      account.reload
      expect(show(account)).to have_alert_for(owner, companion)
    end

    example 'one person has unresolved reqs' do
      create_rec_request('owner', account)
      expect(show(account)).to have_alert_for(owner)
      run!(AdminArea::CardRecommendations::Complete, person_id: owner.id)
      create_rec_request('companion', account)
      account.reload
      expect(show(account)).to have_alert_for(companion)
    end
  end
end
