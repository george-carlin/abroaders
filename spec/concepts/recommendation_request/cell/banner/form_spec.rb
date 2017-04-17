require 'cells_helper'

RSpec.describe RecommendationRequest::Cell::Banner::Form do
  controller RecommendationRequestsController

  let(:cell_class) { described_class }

  # type select is initially hidden, and will be shown by JS. But this is a
  # cell spec and we don't care about the JS
  let(:have_type_select) do
    have_select(:person_type, options: select_options, visible: false)
  end

  let(:have_no_type_select) do
    have_no_select(:person_type)
  end

  BTN_TEXT = 'Request new card recommendations'.freeze

  let(:offer) { create(:offer) }

  describe 'for solo account' do
    let(:account) { create(:account, :onboarded, :eligible) }
    let(:person)  { account.owner }

    example 'ineligible' do
      person.update!(eligible: false)
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
      expect(rendered).to have_link BTN_TEXT
      expect(rendered).to have_no_type_select
    end
  end

  describe 'for couples account' do
    let(:account) { create(:account, :couples, :onboarded, :eligible) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }
    let(:people) { account.people }

    let(:select_options) { [owner.first_name, companion.first_name, 'Both of us'] }
    let(:have_no_generic_btn) do
      have_no_button(BTN_TEXT).and(have_no_link(BTN_TEXT, exact: true))
    end
    let(:companion_survey_link) do
      [
        "Request new card recommendations for #{companion.first_name}",
        { href: new_recommendation_requests_path(person_type: :companion) },
      ]
    end
    let(:owner_survey_link) do # e.g. have_link(*owner_survey_link)
      [
        "Request new card recommendations for #{owner.first_name}",
        { href: new_recommendation_requests_path(person_type: :owner) },
      ]
    end

    example 'neither eligible' do
      people.each { |p| p.update!(eligible: false) }

      expect(cell_class.(account).to_s).to eq ''
    end

    context 'both eligible' do
      example 'both can request' do
        rendered = show(account)
        expect(rendered).to have_button BTN_TEXT
        expect(rendered).to have_type_select
      end

      example 'one has unresolved recs' do
        create_rec(person: companion)
        rendered = show(account)
        expect(rendered).to have_no_generic_btn
        expect(rendered).to have_link(*owner_survey_link)
        expect(rendered).to have_no_link(*companion_survey_link)
        expect(rendered).to have_no_type_select
      end

      example 'one has unresolved request' do
        create_rec_request('owner', account)
        rendered = show(account)
        expect(rendered).to have_no_type_select
        expect(rendered).to have_no_link(*owner_survey_link)
        expect(rendered).to have_link(*companion_survey_link)
        expect(rendered).to have_no_type_select
      end

      example 'both have unresolved recs/reqs' do
        create_rec(person: owner)
        create_rec_request('companion', account)
        rendered = show(account)
        expect(cell_class.(account).to_s).to eq ''
        expect(rendered).to have_no_type_select
      end
    end

    context 'one eligible' do
      # companion is ineligible, owner can request
      before { companion.update!(eligible: false) }

      example 'has unresolved request' do
        create_rec_request('owner', account)
        expect(cell_class.(account).to_s).to eq ''
      end

      example 'has unresolved recs' do
        create_rec(person: owner)
        expect(cell_class.(account).to_s).to eq ''
      end

      example 'can request' do
        rendered = show(account)
        expect(rendered).to have_link(*owner_survey_link)
        expect(rendered).to have_no_type_select
      end
    end
  end
end
