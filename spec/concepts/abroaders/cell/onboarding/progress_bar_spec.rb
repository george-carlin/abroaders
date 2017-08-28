require 'cells_helper'

RSpec.describe Abroaders::Cell::Onboarding::ProgressBar do
  let(:all_states) { Account::Onboarder.workflow_spec.states.keys - [:complete] }

  it 'has a valid value for every possible onboarding state' do
    all_states.each do |state|
      instance = cell(Account.new(onboarding_state: state))
      expect(instance.percentage_complete).not_to be_nil
      expect(instance.phase_number).not_to be_nil
      expect(instance.phase_name).not_to be_nil
    end
  end

  it 'never goes backwards' do
    all_states.each_slice(2) do |state_0, state_1|
      # there'll be a 'nil' on the end when there's an odd number of states:
      next if state_1.nil?
      pb_0 = cell(Account.new(onboarding_state: state_0))
      pb_1 = cell(Account.new(onboarding_state: state_1))

      expect(pb_1.percentage_complete).to be >= pb_0.percentage_complete
      expect(pb_1.phase_number).to be >= pb_0.phase_number
    end
  end
end
