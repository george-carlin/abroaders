require 'cells_helper'

RSpec.describe RecommendationRequest::Cell::Banner::Form do
  let(:cell_class) { described_class }

  # TODO move to sample_data_macros.rb
  def create_rec_request(_person_type, account)
    run!(
      RecommendationRequest::Create,
      { person_type: 'owner' },
      'account' => account,
    )
  end

  BTN_TEXT = 'Request new card recommendations'.freeze

  let(:offer) { create(:offer) }

  describe 'for solo account' do
    let(:account) { create(:account, :onboarded, :eligible) }
    let(:person)  { account.owner }

    example 'ineligible' do
      person.update!(eligible: false)
      # account.eligible_people.reload
      expect(cell_class.(account).to_s).to eq ''
    end

    example 'unresolved request' do
      create_rec_request('owner', account)
      expect(cell_class.(account).to_s).to eq ''
    end

    example 'unresolved recommendations' do
      create_rec(person: person)
      expect(cell_class.(account).to_s).to eq ''
    end

    example 'no unresolved recs/reqs' do
      rendered = show(account)
      expect(rendered).to have_button BTN_TEXT
      # TODO test has no person_select
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
        expect(rendered).to have_button BTN_TEXT
        # TODO test has person_select
      end

      example 'one has unresolved recs' do
        create_rec(person: companion)
        expect(cell_class.(account).to_s).to eq ''
      end

      example 'one has unresolved request' do
        create_rec_request('owner', account)
        # temp solution (see above comment) FIXME
        expect(cell_class.(account).to_s).to eq ''
      end

      example 'both have unresolved recs/reqs' do
        create_rec(person: owner)
        create_rec_request('companion', account)
        expect(cell_class.(account).to_s).to eq ''
      end
    end

    context 'one eligible' do
      # companion is ineligible, owner can request
      before { companion.update!(eligible: false) }

      example 'has unresolved request' do
        create_rec_request('owner', account)
        rendered = show(account)
        expect(rendered).not_to have_button BTN_TEXT
        # TODO test has no person select
      end

      example 'has unresolved recs' do
        create_rec(person: owner)
        rendered = show(account)
        expect(rendered).not_to have_button BTN_TEXT
        # TODO test has no person select
      end

      example 'can request' do
        rendered = show(account)
        expect(rendered).to have_button BTN_TEXT
        # TODO test has no person select
      end
    end
  end
end
