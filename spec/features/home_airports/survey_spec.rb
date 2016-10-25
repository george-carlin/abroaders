require "rails_helper"

describe "home airports survey", :onboarding, :js do
  let(:account)       { create(:account) }
  let(:person)        { account.owner }

  let(:visit_path) do
    login_as account.reload
    visit survey_home_airports_path
  end

  let(:submit_form) { click_button("Save and continue") }

  subject { page }

  before do
    @airport = create(:airport)
    visit_path
  end

  example "initial layout" do
    expect(page).to have_selector("input.typeahead")
    expect(page).to have_button("Save and continue", disabled: true)
    expect(page).to have_no_sidebar
  end

  xexample "work of autocomplete" do
    select = "#{@airport.parent.name} #{@airport.name} (#{@airport.code})"
    with = @airport.code
    field = "typeahead"

    find(field).native.send_keys(with.chars)

    page.execute_script("$('##{field}').trigger('focus');")
    page.execute_script "$('##{field}').trigger('keydown');"
    selector = ".tt-menu .tt-dataset div.tt-suggestion"
    expect(page).to have_selector(selector, text: select)
    page.execute_script("$(\"#{selector}\").mouseenter().click()")
    expect(page).to have_selector(".airport-selected p", text: select)
    expect(page).to have_button("Save and continue", disabled: false)
  end

  example "submitting form" do
    fill_in_typeahead("#typeahead", with: @airport.code, and_choose: @airport.code)
    submit_form
    account.reload
    expect(account.home_airports.count).to eq 1
    expect(account.onboarded_home_airports).to eq true
    expect(account.home_airports.first).to eq @airport
    expect(current_path).to eq new_travel_plan_path
  end
end
