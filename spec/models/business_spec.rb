require 'business'

RSpec.describe Business do
  let(:spending_info_class) { Struct.new(:has_business, :business_spending_usd) }

  example '.build' do
    # when there is no business
    spending = spending_info_class.new('no_business', nil)
    expect(described_class.build(spending)).to be_nil

    # business with ein:
    spending = spending_info_class.new('with_ein', 1234)
    business = described_class.build(spending)
    expect(business.ein).to be true
    expect(business.spending_usd).to eq 1234

    # business without ein:
    spending = spending_info_class.new('without_ein', 4321)
    business = described_class.build(spending)
    expect(business.ein).to be false
    expect(business.spending_usd).to eq 4321
  end
end
