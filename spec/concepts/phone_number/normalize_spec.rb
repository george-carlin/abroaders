require 'rails_helper'

describe PhoneNumber::Normalize do
  example '.normalize' do
    expect(described_class.('123412345')).to eq '123412345'
    expect(described_class.('123-41a23 4 -+AIWJER 5')).to eq '123412345'
  end
end
