require "rails_helper"

describe "home airports survey", :onboarding, :js do
  let(:account)       { create(:account) }
  let(:person)        { account.owner }

  let(:visit_path) do
    login_as account.reload
    visit survey_airports_path
  end

  let(:submit_form) { click_button "Save" }

  subject { page }

  before do
    @airport = create(:airport)
    visit_path
  end

  def fill_in_autocomplete(field, with)
    fill_in field, with: with

    page.execute_script("$('##{field}').trigger('focus');")
    page.execute_script ("$('##{field}').trigger('keydown');")
    selector = ".tt-menu .tt-dataset div.tt-suggestion"
    page.execute_script("$(\"#{selector}\").mouseenter().click()")
  end

  example "initial layout" do
    # for an input typeahead generates an additional input, so total count is 2
    expect(page).to have_selector("input.typeahead", count: 2)
    expect(page).to have_selector(".btn-add", count: 1)
    expect(page).to have_no_selector(".btn-remove")
    expect(page).to have_no_sidebar
  end

  example "add more airport fields" do
    click_on "Add an additional home airport"
    expect(page).to have_selector("input.typeahead", count: 4)
    expect(page).to have_selector(".btn-remove", count: 1)
    click_on "Add an additional home airport"
    expect(page).to have_selector("input.typeahead", count: 6)
    expect(page).to have_selector(".btn-remove", count: 2)
    first(".btn-remove").click
    first(".btn-remove").click
    expect(page).to have_selector("input.typeahead", count: 2)
    expect(page).to have_no_selector(".btn-remove")
  end

  example "work of autocomplete" do
    select = "#{@airport.parent.name} (#{@airport.code})"
    with = @airport.name
    field = "typeahead"

    fill_in field, with: with

    page.execute_script("$('##{field}').trigger('focus');")
    page.execute_script ("$('##{field}').trigger('keydown');")
    selector = ".tt-menu .tt-dataset div.tt-suggestion"
    expect(page).to have_selector(selector, text: select)
    page.execute_script("$(\"#{selector}\").mouseenter().click()")
    expect(page).to have_field(field, with: select)
  end

  example "submittin form with valid data" do
    fill_in_autocomplete("typeahead", @airport.name)
    submit_form
    account.reload
    expect(account.home_airports.count).to eq 1
    expect(account.onboarded_home_airports).to eq true
    expect(account.home_airports.first).to eq @airport
    expect(current_path).to eq new_travel_plan_path
  end

  example "submittin form with invalid data" do
    fill_in("typeahead", with: @airport.name)
    submit_form
    account.reload
    expect(account.home_airports.count).to eq 0
    expect(account.onboarded_home_airports).to eq false
    expect(current_path).to eq survey_airports_path
  end
end
