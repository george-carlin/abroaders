require 'rails_helper'

RSpec.describe Bank::Form do
  def errors_for(attrs)
    form = described_class.new(Bank.new)
    form.validate(attrs)
    form.errors
  end

  example 'validation' do
    attrs = { name: nil, business_phone: nil, personal_phone: nil }
    expect(errors_for(attrs)[:name]).not_to be_empty
    attrs[:name] = '  '
    expect(errors_for(attrs)[:name]).not_to be_empty
    attrs[:name] = 'Wells Fargo'
    expect(errors_for(attrs)[:name]).to be_empty
  end

  example 'stripping strings' do
    bank = create(:bank)
    attrs = {
      name:           '  Wells Fargo  ',
      business_phone: '  555 1234-000  ',
      personal_phone: '  555 0000-123  ',
    }
    form = described_class.new(bank)
    expect(form.validate(attrs)).to be true
    form.save
    bank.reload
    expect(bank.name).to eq('Wells Fargo')
    expect(bank.business_phone).to eq('555 1234-000')
    expect(bank.personal_phone).to eq('555 0000-123')
  end
end
