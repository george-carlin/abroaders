require "rails_helper"

describe CardAccount::State do
  describe "#reachable?" do
    let(:state) { described_class.new(status, reconsidered) }

    def self.should_be_reachable(*reachable_states)
      reachable_states = reachable_states.map do |(status, reconsidered)|
        described_class.new(status, reconsidered)
      end

      described_class::GRAPH.keys.each do |target_state|
        describe "the state '#{target_state.status}, #{target_state.reconsidered}'" do
          if reachable_states.include?(target_state)
            it "is reachable" do
              expect(state.reachable?(target_state)).to be true
            end
          else
            it "is not reachable" do
              expect(state.reachable?(target_state)).to be false
            end
          end
        end
      end
    end

    %w[recommended clicked].each do |_status|
      context "when status is #{_status}" do
        let(:status) { _status }
        context "and account is not reconsidered" do
          let(:reconsidered) { false }

          should_be_reachable(
            ["clicked",  false],
            ["declined", false],
            ["open",     false],
            ["pending",  false],
            ["denied",   false],
          )
        end
      end
    end

    context "when status is declined" do
      let(:status) { "declined" }
      context "and account is not reconsidered" do
        let(:reconsidered) { false }
        # No states are reachable:
        should_be_reachable()
      end
    end

    context "when status is pending" do
      let(:status) { "pending" }
      context "and account is not reconsidered" do
        let(:reconsidered) { false }

        should_be_reachable(
          ["open",    false],
          ["denied",  false],
          ["pending", true],
          ["open",    true],
          ["denied",  true],
        )
      end

      context "and account is reconsidered" do
        let(:reconsidered) { true }

        should_be_reachable(
          ["open",   true],
          ["denied", true],
        )
      end
    end

    context "when status is denied" do
      let(:status) { "denied" }
      context "and account is not reconsidered" do
        let(:reconsidered) { false }

        should_be_reachable(
          ["denied",  true],
          ["open",    true],
          ["pending", true],
        )
      end

      context "and account is reconsidered" do
        let(:reconsidered) { true }
        # No states are reachable:
        should_be_reachable()
      end
    end

    context "when status is open" do
      let(:status) { "open" }
      context "and account is not reconsidered" do
        let(:reconsidered) { false }
        # No states are reachable:
        should_be_reachable()
      end

      context "and account is reconsidered" do
        let(:reconsidered) { true }
        # No states are reachable:
        should_be_reachable()
      end
    end
  end
end
