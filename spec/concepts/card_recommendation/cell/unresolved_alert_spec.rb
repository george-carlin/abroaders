require 'cells_helper'

RSpec.describe CardRecommendation::Cell::UnresolvedAlert do
  include_context 'recommendation alert cell'

  let(:header) { 'Your Card Recommendations are Ready' }

  context 'solo account' do
    let(:account) { create(:account, :eligible, :onboarded) }
    let(:person)  { account.owner }

    def have_alert
      have_content(header).and(
        have_content('We have posted your card recommendations').and(
          have_link('Continue'),
        ),
      )
    end

    example 'with unresolved recommendations' do
      create_rec_request('owner', account)
      # unresolved rec:
      create_rec(person: person)
      # and a resolved one:
      create_rec(person: person).update!(applied_on: Date.today)
      rendered = show(account)
      expect(rendered).to have_alert
    end

    example 'with no recs' do
      create_rec_request('owner', account)
      is_invalid
    end

    example 'with recs, but all are resolved' do
      create_rec_request('owner', account)
      # some resolved recs:
      decline_rec(create_rec(person: person))
      create_rec(person: person).update!(applied_on: Date.today)
      is_invalid
    end

    example 'with ineligible person' do
      # technically, ineligible people can still receive recs from an admin, so
      # the alert may still be shown:
      person.update!(eligible: false)
      create_rec(person: person)
      rendered = show(account)
      expect(rendered).to have_alert
    end
  end

  context 'couples account' do
    let(:account) { create(:account, :couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }
    let(:people) { account.people }

    def have_alert_for(*people_with_recs)
      names = people_with_recs.map(&:first_name).join(' and ')
      have_content(header).and(
        have_content("We have posted card recommendations for #{names}").and(
          have_link('Continue'),
        ),
      )
    end

    example 'neither eligible' do
      # ineligible people can still receive recs from an admin, so the alert
      # may still be shown:
      people.each { |p| p.update!(eligible: false) }
      owner_rec = create_rec(person: owner)
      expect(show(account)).to have_alert_for(owner)
      create_rec(person: companion)
      account.reload
      expect(show(account)).to have_alert_for(owner, companion)
      # resolve owner_rec:
      owner_rec.update!(applied_on: Date.today)
      account.reload
      expect(show(account)).to have_alert_for(companion)
    end

    # owner eligible, companion not. Not bothering to test the other way around
    context 'one eligible' do
      before { companion.update!(eligible: false) }

      example 'with unresolved recommendations' do
        create_rec_request('owner', account)
        # unresolved rec:
        create_rec(person: owner)
        # and a resolved one:
        create_rec(person: owner).update!(applied_on: Date.today)
        rendered = show(account)
        expect(rendered).to have_alert_for(owner)
      end

      example 'no recs' do
        create_rec_request('owner', account)
        is_invalid
      end

      example 'all recs are resolved' do
        create_rec_request('owner', account)
        # create resolved recs:
        decline_rec(create_rec(person: owner))
        create_rec(person: owner).update!(applied_on: Date.today)
        is_invalid
      end

      example 'ineligible person has recs too' do
        create_rec(person: companion)
        expect(show(account)).to have_alert_for(companion)
      end
    end

    context 'both eligible' do
      example 'with unresolved recommendations' do
        owner_rec =  create_rec(person: owner)
        expect(show(account)).to have_alert_for(owner)
        create_rec(person: companion)
        account.reload
        expect(show(account)).to have_alert_for(owner, companion)
        # resolve owner rec:
        owner_rec.update!(applied_on: Date.today)
        account.reload
        expect(show(account)).to have_alert_for(companion)
      end

      example 'no recs' do
        create_rec_request('both', account)
        is_invalid
      end

      example 'all recs are resolved' do
        create_rec_request('owner', account)
        decline_rec(create_rec(person: owner))
        create_rec(person: owner).update!(applied_on: Date.today)
        is_invalid
      end
    end

    it 'avoids XSS' do
      create_rec(person: owner)
      create_rec(person: companion)
      owner.update!(first_name: '<script>')
      companion.update!(first_name: '</script>')

      rendered = show(account).to_s
      expect(rendered).to include "&lt;script&gt;"
      expect(rendered).to include "&lt;/script&gt;"
    end
  end
end
