require 'rails_helper'

RSpec.describe Person::Cell::ReadinessIcon do
  let(:person) { Struct.new(:ready?, :eligible?).new(r, el) }
  subject(:cell) { described_class.(person).() }

  context 'when person is ready' do
    let(:r)  { true }
    let(:el) { true }
    it { is_expected.to eq '(R)' }
  end

  context 'when person is eligible but not ready' do
    let(:r)  { false }
    let(:el) { true }
    it { is_expected.to eq '(E)' }
  end

  context 'when person is ineligible' do
    let(:r)  { false }
    let(:el) { false }
    it { is_expected.to eq '' }
  end
end
