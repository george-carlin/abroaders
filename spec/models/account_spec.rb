require "rails_helper"

describe Account do
  let(:account) { described_class.new }

  describe "#onboarded?" do
    subject { account.onboarded? }

    context "when the account has not onboarded travel plans" do
      it { is_expected.to be false }
    end

    context "when the account has onboarded travel plans" do
      before { account.onboarded_travel_plans = true }

      context "and has not onboarded type" do
        it { is_expected.to be false }

        context "and has onboarded type" do
          before { account.onboarded_type = true }

          context "and has no people" do
            it { is_expected.to be false }
          end

          context "and has added people" do
            before { account.people.build }
            context "and not all people are onboarded" do
              it { is_expected.to be false }
            end

            context "and all people are onboarded" do
              before do
                account.people.each do |p|
                  allow(p).to receive(:onboarded?) { true }
                end
              end
              it { is_expected.to be true }
            end
          end
        end
      end
    end
  end
end
