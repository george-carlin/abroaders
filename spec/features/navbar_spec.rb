require "rails_helper"

describe "navbar" do
  subject { page }

  describe "as a user" do

    include_context "logged in as new user"

    before do
      user.create_info!(
        attributes_for(
          :user_info, user: nil,
          has_completed_card_survey: i_have_completed_cards_survey
        )
      ) if i_have_completed_user_info_survey
      visit root_path
    end

    let(:i_have_completed_user_info_survey) { false }
    let(:i_have_completed_cards_survey) { false }

    shared_examples "no cards or travel plans links" do
      it "does not contain links to 'Cards' or 'Travel Plans'" do
        within "#main_navbar" do
          is_expected.not_to have_link "Cards"
          is_expected.not_to have_link "Travel Plans"
        end
      end
    end

    context "who has not completed any part of the onboarding survey" do
      include_examples "no cards or travel plans links"
    end

    context "who has completed the contact/spending info survey" do
      let(:i_have_completed_user_info_survey) { true }

      context "but not the cards survey" do
        include_examples "no cards or travel plans links"
      end

      context "and the cards survey" do
        let(:i_have_completed_cards_survey) { true }
        pending # TODO come back to this when we've added the rest of the survey steps
      end
    end
  end
end
