require 'rails_helper'

RSpec.describe Person::Cell::Admin::SpendingInfo, type: :view do
  let(:person)   { Struct.new(:spending_info).new(info) }
  subject(:cell) { described_class.(person).show }

  context 'when person has no spending info' do
    let(:info) { nil }
    it { is_expected.to eq 'User has not added their spending info' }
  end

  context 'when person has spending info' do
    let(:info) { build(:spending_info) }
    it { is_expected.not_to have_content 'User has not added their spending info' }
  end
end
