require "rails_helper"

describe BalancesSurvey do

  describe "#send_survey_complete_notification?" do
    # Yes, I know that testing a private method is normally a bad idea,
    # but the conditionals are fiddly and I want to get it right

    before do
      @account = Account.new
      @account.build_owner
      if i_am_owner?
        @person = @account.owner
        @account.build_companion if has_companion?
      else
        @person = @account.build_companion
      end

      # Without this line @person.account will be nil :/
      @person.account = @account
      # This is necessary too or has_companion? will always return false because
      # the companion isn't persisted :/
      allow(@account).to receive(:has_companion?) { has_companion? }

      allow(@person).to receive(:eligible?) { eligible? }
      @survey = BalancesSurvey.new(@person)
    end

    subject { @survey.send(:send_survey_complete_notification?) }

    context "when I am the main person" do
      let(:i_am_owner?) { true }

      context "and I have a companion" do
        let(:has_companion?) { true }
        context "and I'm eligible to apply for cards" do
          let(:eligible?) { true }
          it { is_expected.to be false }
        end

        context "and I'm not eligible to apply for cards" do
          let(:eligible?) { false }
          it { is_expected.to be false }
        end
      end

      context "and I don't have a companion" do
        let(:has_companion?) { false }
        context "and I'm eligible to apply for cards" do
          let(:eligible?) { true }
          it { is_expected.to be false }
        end

        context "and I'm not eligible to apply for cards" do
          let(:eligible?) { false }
          it { is_expected.to be true }
        end
      end
    end

    context "when I am the companion" do
      let(:has_companion?) { true }
      let(:i_am_owner?) { false }

      context "and I'm eligible to apply for cards" do
        let(:eligible?) { true }
        it { is_expected.to be false }
      end

      context "and I'm not eligible to apply for cards" do
        let(:eligible?) { false }
        it { is_expected.to be true }
      end
    end
  end

  # Yes, I just wrote 70+ lines of code to test a one-line method. I'm sorry.
end
