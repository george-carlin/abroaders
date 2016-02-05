require "rails_helper"

describe User do

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
    it { is_expected.to delegate_method(method).to(:info) }
  end

  describe "#has_completed_onboarding_survey?" do
    let(:user) { build_stubbed(:user) }
    subject { user.has_completed_onboarding_survey? }

    context "when the user" do
      context "has not completed any part of the survey" do
        it { is_expected.to be_falsey }
      end

      context "has completed the contact/spending info survey" do
        before do
          user.build_info
          allow(user.info).to receive(:persisted?).and_return true
        end

        context "but not the cards survey" do
          it { is_expected.to be_falsey }
        end

        context "and the cards survey" do
          before { user.info.has_completed_card_survey = true }
          pending # TODO come back to this when we've added the rest of the survey steps
        end
      end
    end
  end
end
