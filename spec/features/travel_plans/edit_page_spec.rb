require 'rails_helper'

RSpec.describe 'edit travel plan page' do
  let(:account) { create(:account, :onboarded) }
  let(:person) { account.owner }

  subject { page }

  let(:submit_form) { click_button 'Save my travel plan' }

  let(:airports) { create_list(:airport, 2) }
  let!(:travel_plan) do
    TravelPlan::Operations::Create.(
      {
        travel_plan: {
          type: 'return',
          depart_on: Date.today + 1,
          return_on: Date.today + 10,
          from: airports[0].full_name,
          to:   airports[1].full_name,
        },
      },
      'account' => account,
    )
    create(:travel_plan, :return, account: account)
  end

  before do
    login_as(account)
    visit edit_travel_plan_path(travel_plan)
  end

  it_behaves_like "a travel plan form"

  it { is_expected.to have_title full_title("Edit Travel Plan") }

  example 'valid update', :js do
    fill_in_typeahead(
      "#travel_plan_from",
      with:       airports[0].code,
      and_choose: "(#{airports[0].code})",
    )

    fill_in_typeahead(
      "#travel_plan_to",
      with:       airports[1].code,
      and_choose: "(#{airports[1].code})",
    )

    set_datepicker_field('#travel_plan_depart_on', to: '01/02/2020')
    set_datepicker_field('#travel_plan_return_on', to: '12/02/2025')

    submit_form
    travel_plan.reload

    # travel plan is updated:
    expect(travel_plan.depart_on).to eq Date.new(2020, 1, 2)
    expect(travel_plan.return_on).to eq Date.new(2025, 12, 2)

    # show travel plan index:
    expect(page).to have_selector 'h1', text: 'My Travel Plans'
  end

  example 'invalid update', :js do
    # return before departure:
    set_datepicker_field('#travel_plan_depart_on', to: '01/02/2030')
    set_datepicker_field('#travel_plan_return_on', to: '01/02/2025')

    return_on_before_save = travel_plan.return_on
    submit_form
    # travel plan not updated:
    expect(travel_plan.reload.return_on).to eq return_on_before_save

    # show form again with error message:
    expect(page).to have_selector "#edit_travel_plan_#{travel_plan.id}"
    expect(page).to have_error_message
  end
end
