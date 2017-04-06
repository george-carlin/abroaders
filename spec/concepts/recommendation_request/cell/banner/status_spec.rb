require 'cells_helper'

# TODO the specs are written, but this cell is less urgent than some
# other ones I need to get done. Postpone creating the cell for now.
#
# Note that this specs are actually wrong, because they test additional
# behaviour that shouldn't be part of the tested cell (like the 'Request a Rec'
# button, which is implemented elsewhere.)
RSpec.describe RecommendationRequest::Cell::Banner::Status do
  before { skip }
  let(:cell_class) { described_class }

  describe 'for solo account' do
    let(:account) { create(:account, :onboarded, :eligible) }
    let(:person)  { account.owner }

    example 'ineligible' do
      person.update!(eligible: false)
      account.reload # TODO is this actually necessary?

      expect(cell_class.(account).to_s).to eq ''
      # TODO test uses 'You', not name
    end

    example 'unresolved request' do
      run!(RecommendationRequest::Create, { person_type: 'owner' }, 'account' => account)
      rendered = show(account)
      expect(rendered).to have_link nil, href: new_recommendation_requests_path
      # TODO test uses 'You', not name
    end

    example 'unresolved recommendations' do
      create_rec(person: person)
      rendered = show(account)
      expect(rendered).to have_link nil, href: cards_path
      # TODO test uses 'You', not name
    end

    example 'no unresolved recs/reqs' do
      rendered = show(account)
      expect(rendered).not_to have_link nil, href: new_recommendation_requests_path
      expect(rendered).not_to have_link nil, href: cards_path
      # TODO test has no person_select
      # TODO test uses 'You', not name
    end
  end

  describe 'for couples account' do
    let(:account) { create(:account, :couples, :onboarded, :eligible) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }
    let(:people) { account.people }

    example 'neither eligible' do
      people.each { |p| p.update!(eligible: false) }
      account.reload # TODO necessary?

      expect(cell_class.(account).to_s).to eq ''
    end

    context 'both eligible' do
      example 'both can request' do
        rendered = show(account)
        expect(rendered).not_to have_link nil, href: new_recommendation_requests_path
        expect(rendered).not_to have_link nil, href: cards_path
        # TODO test has person_select
      end

      example 'one has unresolved recs' do
        create_rec(person: companion)
        expect(rendered).to have_link nil, href: cards_path
        # TODO let them request recs for the other person
      end

      example 'one has unresolved request' do
        run!(RecommendationRequest::Create, { person_type: 'owner' }, 'account' => account)
        rendered = show(account)
        expect(rendered).to have_link nil, href: new_recommendation_requests_path
      end

      example 'both have unresolved recs/reqs' do
        create_rec(person: owner)
        run!(RecommendationRequest::Create, { person_type: 'companion' }, 'account' => account)
        rendered = show(account)
        expect(rendered).to have_link nil, href: new_recommendation_requests_path
        expect(rendered).to have_link nil, href: cards_path
      end
    end

    context 'one eligible' do
      before { owner.update!(eligible: false) }

      example 'has unresolved request' do
        run!(RecommendationRequest::Create, { person_type: 'companion' }, 'account' => account)
        rendered = show(account)
        expect(rendered).to have_link nil, href: new_recommendation_requests_path
        # TODO test uses name, not 'You'
      end

      example 'has unresolved recs' do
        create_rec(person: companion)
        rendered = show(account)
        expect(rendered).to have_link nil, href: cards_path
        # TODO test uses name, not 'You'
      end

      example 'can request' do
        rendered = show(account)
        expect(rendered).not_to have_link nil, href: new_recommendation_requests_path
        expect(rendered).not_to have_link nil, href: cards_path
        # TODO test has no person_select
        # TODO test uses name, not 'You'
      end
    end
  end
end
