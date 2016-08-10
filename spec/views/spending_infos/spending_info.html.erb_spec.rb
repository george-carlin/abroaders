require "rails_helper"

describe "spending_info/spending_info" do

  let(:spending_info) do
    build(
      :spending_info,
      has_business: has_business,
      business_spending_usd: business_spending_usd,
    )
  end

  let(:rendered) do
    locals = { spending_info: spending_info }
    render partial: "spending_infos/spending_info", locals: locals
  end
  subject { rendered }

  let(:business_spending_usd) { 0 }

  context "when the person has no business" do
    let(:has_business) { "no_business" }
    it "says 'No business'" do
      expect(rendered).to have_content "No business"
      expect(rendered).not_to have_selector ".has-ein"
      expect(rendered).not_to have_selector ".spending-info-business-spending"
    end
  end

  context "when the person has a business with EIN" do
    let(:has_business) { "with_ein" }
    let(:business_spending_usd) { 1234 }
    it "displays the business information" do
      expect(rendered).not_to have_content "No business"
      expect(rendered).to have_selector ".has-ein", text: "Has EIN"
      expect(rendered).to have_selector ".spending-info-business-spending", text: "$1,234.00"
    end
  end

  context "when the person has a business with no EIN" do
    let(:has_business) { "without_ein" }
    let(:business_spending_usd) { 1234 }
    it "displays the business information" do
      expect(rendered).not_to have_content "No business"
      expect(rendered).to have_selector ".has-ein", text: "Does not have EIN"
      expect(rendered).to have_selector ".spending-info-business-spending", text: "$1,234.00"
    end
  end

end
