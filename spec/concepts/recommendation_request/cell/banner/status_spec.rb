require 'cells_helper'

RSpec.describe RecommendationRequest::Cell::Banner::Status do
  controller RecommendationRequestsController
  let(:cell_class) { described_class }

  let(:account) { create(:account, :onboarded, :eligible) }
  let(:person)  { account.owner }
  let(:owner)   { person }

  describe 'for solo account' do
    example 'ineligible' do
      person.update!(eligible: false)
      expect(cell_class.(account).to_s).to eq ''
    end

    example 'unresolved request' do
      create_rec_request('owner', account)
      rendered = show(account)
      expect(rendered).to have_content 'You requested recommendations'
    end

    example 'unresolved recommendations' do
      create_rec(person: person)
      rendered = show(account)
      expect(rendered).to have_link nil, href: cards_path
      expect(rendered).to have_content 'You have card recommendations that require action'
    end

    example 'no unresolved recs/reqs (can make request)' do
      expect(cell_class.(account).to_s).to eq ''
    end

    # This may happen if an admin does something weird; handle it just in case
    example 'has unresolved recs AND an unresolved request' do
      create_rec_request('owner', account)
      create_rec(person: person)
      rendered = show(account)
      expect(rendered).to have_link nil, href: cards_path
      expect(rendered).to have_content 'You have card recommendations that require action'
      expect(rendered).to have_content 'You requested recommendations'
    end
  end

  describe 'for couples account' do
    let(:account) { create(:account, :couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }
    let(:people) { account.people }

    example 'neither eligible' do
      people.each { |p| p.update!(eligible: false) }
      expect(cell_class.(account).to_s).to eq ''
    end

    context 'both eligible' do
      example 'both can request' do
        expect(cell_class.(account).to_s).to eq ''
      end

      example 'one has unresolved request' do
        create_rec_request('owner', account)
        rendered = show(account)
        expect(rendered).to have_content(
          "You requested recommendations for #{owner.first_name}",
        )
      end

      example 'one has unresolved recs' do
        create_rec(person: companion)
        rendered = show(account)
        expect(rendered).to have_link nil, href: cards_path
        expect(rendered).to have_content(
          "#{companion.first_name} has card recommendations that require action",
        )
      end

      example 'both have unresolved recs/reqs' do
        create_rec_request('both', account)
        account.reload
        create_rec(person: owner)
        create_rec(person: companion)
        rendered = show(account)
        expect(rendered).to have_link nil, href: cards_path
        names = [owner.first_name, companion.first_name].join(' and ')
        expect(rendered).to have_content(
          "You requested recommendations for #{names}",
        )
        expect(rendered).to have_content(
          "#{names} have card recommendations that require action",
        )
      end
    end

    context 'one eligible' do
      before { owner.update!(eligible: false) }

      example 'has unresolved request' do
        create_rec_request('companion', account)
        rendered = show(account)
        expect(rendered).to have_content(
          "You requested recommendations for #{companion.first_name}",
        )
      end

      example 'has unresolved recs' do
        create_rec(person: companion)
        rendered = show(account)
        expect(rendered).to have_link nil, href: cards_path
        expect(rendered).to have_content companion.first_name
        expect(rendered).to have_content(
          "#{companion.first_name} has card recommendations that require action",
        )
      end

      example 'can request' do
        expect(cell_class.(account).to_s).to eq ''
      end
    end
  end

  it 'avoids XSS' do
    account.owner.update!(first_name: '<evil>')
    companion = account.create_companion!(eligible: true, first_name: '<knievel>')

    create_rec_request('both', account.reload)
    create_rec(person: owner)
    create_rec(person: companion)

    rendered = show(account.reload).to_s # test fails if you don't reload account
    names = "&lt;evil&gt; and &lt;knievel&gt;"
    expect(rendered).to include "recommendations for #{names}"
    expect(rendered).to include "#{names} have card recommendations"
  end
end
