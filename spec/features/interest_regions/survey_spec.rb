require "rails_helper"

describe "interest regions survey", :js do
  def check_checkbox(name)
    find(:checkbox, name).trigger("click")
  end

  before do
    @regions = create_list(:region, 3)
    @account = create(:account, :onboarded)
    login_as(@account)
    visit survey_interest_regions_path
  end

  let(:submit_form) { click_on "Save and continue" }

  example "initial page layout" do
    expect(page).to have_no_selector "#menu"
    expect(page).to have_button "Save and continue"
    expect(page).to have_content "Interested in any of these locations?"
    @regions.each do |region|
      expect(page).to have_content region.name
      expect(page).to have_field "interest_regions_survey_#{region.id}_region_selected"
    end
  end

  example "selecting some regions" do
    check_checkbox("interest_regions_survey_#{@regions[0].id}_region_selected")
    check_checkbox("interest_regions_survey_#{@regions[1].id}_region_selected")
    expect{submit_form}.to change{InterestRegion.count}.by(2)
    expect(InterestRegion.last.account).to eq(@account)
    expect(InterestRegion.last.region).to eq(@regions[1])
    expect(current_path).to eq(root_path)
  end

  example "selecting none" do
    expect{submit_form}.not_to change{InterestRegion.count}
    expect(current_path).to eq(root_path)
  end
end
