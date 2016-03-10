require "rails_helper"

describe Account do

  %i[
    business_spending
    citizenship
    credit_score
    first_name
    full_name
    has_business
    has_business?
    has_business_with_ein?
    has_business_without_ein?
    imessage
    imessage?
    last_name
    middle_names
    personal_spending
    phone_number
    text_message
    text_message?
    time_zone
    whatsapp
    whatsapp?
    will_apply_for_loan
  ].each do |method|
    it { is_expected.to delegate_method(method).to(:survey) }
  end

  describe "#survey_complete?" do
    let(:account) { build_stubbed(:account) }
    subject { account.survey_complete? }

    context "when the account" do
      context "has not completed any part of the survey" do
        it { is_expected.to be_falsey }
      end

      context "has completed the main survey" do
        before do
          account.build_survey
          allow(account.survey).to receive(:persisted?).and_return true
        end

        context "but not the cards survey" do
          it { is_expected.to be_falsey }
        end

        context "and the cards survey" do
          before { account.survey.has_added_cards = true }

          context "but not the balances survey" do
            it { is_expected.to be_falsey }
          end

          context "and the balances survey" do
            before { account.survey.has_added_balances = true }
            it { is_expected.to be_truthy }
          end
        end
      end
    end
  end


  # Scopes


  describe ".onboarded" do
    it "returns only non-admins who have completed the onboarding survey" do
      create(:account)                         # no survey
      create(:account, :completed_main_survey) # no card accounts
      create(:account, :completed_card_survey) # no balances
      create(:admin)                        # admin
      onboarded_account = create(:account, :survey_complete)
      expect(User.onboarded).to match_array [onboarded_account]
    end
  end
end
