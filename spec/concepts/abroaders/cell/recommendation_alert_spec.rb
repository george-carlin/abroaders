require 'cells_helper'

RSpec.describe Abroaders::Cell::RecommendationAlert do
  include_context 'create_rec avoids extra records'

  let(:cell_class) { described_class }

  EXCLUDED_ACTIONS = {
    'recommendation_requests' => %w[new create],
  }.freeze

  def render # use this method when you don't want to memoize the result
    cell_class.(account, context: { controller: CellContextController.new }).to_s
  end

  # test that the cell renders '"" when the current action is included in the
  # list of excluded actions. This only tests for the actions that are excluded
  # for ALL instances of the cell. For actions which are only excluded for a
  # particular subclass (i.e. cards#index), a separate test must be written.
  def is_excluded
    params = {}
    EXCLUDED_ACTIONS.each do |ctrlr, actions|
      params['controller'] = ctrlr
      actions.each do |action|
        params['action'] = action
        expect(cell_with_params(params).to_s).to eq ''
      end
    end
  end

  let(:rendered) { render }

  class CellContextController
    include Rails.application.routes.url_helpers

    attr_accessor :params

    def protect_against_forgery?
      false
    end
  end

  def cell_with_params(params)
    controller = CellContextController.new
    controller.params = params
    cell_class.(account, context: { controller: controller })
  end

  def show_unresolved_requests_alert
    match(/Abroaders is Working on .* Recommendations/)
  end

  def show_unresolved_recs_alert
    include 'Your Card Recommendations are Ready'
  end

  def show_recs_cta
    include 'Want to Earn More Rewards Points?'
  end

  # examples expect a let variable called 'person' to be present
  shared_examples 'one eligible person' do
    example 'with unresolved request' do
      create_rec_request(person.type, account)
      # create some resolved recommendations too
      create_rec(person: person).update!(applied_on: Date.today)
      decline_rec(create_rec(person: person))
      account.reload
      expect(rendered).to show_unresolved_requests_alert
    end

    example 'with unresolved recs' do
      # if they have both unresolved requests and unresolved recs (which is
      # technically possibly, e.g. if an admin does something weird), the recs
      # take priority:
      create_rec_request(person.type, account)
      create_rec(person: person)
      expect(rendered).to show_unresolved_recs_alert
    end

    example 'who can request' do
      # create recs/reqs but resolve them
      create_rec_request(person.type, account)
      create_rec(person: person).update!(applied_on: Date.today)
      complete_recs(person)
      expect(rendered).to show_recs_cta
    end

    example 'with non-onboarded account' do
      account.onboarding_state = 'phone_number'
      expect(rendered).to eq ''
    end

    example 'onboarded but on excluded paths' do
      # when Request CTA is to be shown
      is_excluded

      # When Unresolved Requests Alert is to be shown
      create_rec_request(person.type, account)
      is_excluded

      # When Unresolved Recommendations Alert is to be shown
      create_rec(person: person)
      is_excluded
    end

    example 'onboarded on cards#index page' do
      # special case: only the unresolved recs alert is hidden; other subclasses
      # are shown
      params = { 'controller' => 'cards', 'action' => 'index' }

      # when Request CTA is to be shown
      expect(cell_with_params(params).to_s).to show_recs_cta

      # When Unresolved Requests Alert is to be shown
      create_rec_request(person.type, account)
      expect(cell_with_params(params).to_s).to show_unresolved_requests_alert

      # Special case ahoy:
      create_rec(person: person)
      expect(cell_with_params(params).to_s).to eq ''
    end
  end

  describe 'for solo account' do
    let(:account) { create(:account, :eligible, :onboarded) }
    let(:person)  { account.owner }

    example 'ineligible' do
      person.update!(eligible: false)
      account.reload
      expect(rendered).to eq ''
    end

    include_examples 'one eligible person'
  end

  describe 'for couples account' do
    let(:account) { create(:account, :couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }

    example 'neither eligible' do
      account.people.update_all(eligible: false)
      account.reload
      expect(rendered).to eq ''
    end

    context 'one eligible' do
      before { owner.update!(eligible: false) }
      let(:person) { companion }

      include_examples 'one eligible person'
    end

    context 'both eligible' do
      example 'one or both have unresolved recs' do
        c_rec = create_rec(person: companion)
        expect(render).to show_unresolved_recs_alert
        create_rec(person: owner)
        expect(render).to show_unresolved_recs_alert
        c_rec.update!(applied_on: Date.today)
        expect(render).to show_unresolved_recs_alert
      end

      example 'one or both have unresolved request' do
        create_rec_request('owner', account)
        expect(render).to show_unresolved_requests_alert

        RecommendationRequest.destroy_all
        create_rec_request('companion', account)
        expect(render).to show_unresolved_requests_alert

        RecommendationRequest.destroy_all
        create_rec_request('both', account.reload)
        expect(render).to show_unresolved_requests_alert
      end

      example 'neither has unresolved recs or requests' do
        # create some recs/requests but resolve them
        create_rec_request('both', account)
        decline_rec(create_rec(person: owner))
        create_rec(person: companion).update!(applied_on: Date.today)

        complete_recs(person)
        expect(rendered).to show_recs_cta
      end

      example 'not onboarded' do
        account.update!(onboarding_state: 'phone_number')
        expect(rendered).to eq ''
      end

      example 'on excluded paths' do
        # when Request CTA is to be shown
        is_excluded

        # When Unresolved Requests Alert is to be shown
        create_rec_request('both', account)
        is_excluded

        # When Unresolved Recommendations Alert is to be shown
        create_rec(person: companion)
        is_excluded
      end

      example 'onboarded on cards#index page' do
        params = { 'controller' => 'cards', 'action' => 'index' }

        # when Request CTA is to be shown
        expect(cell_with_params(params).to_s).to show_recs_cta

        # When Unresolved Requests Alert is to be shown
        create_rec_request('owner', account)
        expect(cell_with_params(params).to_s).to show_unresolved_requests_alert

        # Special case ahoy:
        create_rec(person: owner)
        account.reload
        expect(cell_with_params(params).to_s).to eq ''
      end
    end
  end
end
