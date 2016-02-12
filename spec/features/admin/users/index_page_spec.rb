require "rails_helper"

describe "admin section" do
  describe "user pages index page", js: true do
    subject { page }

    include_context "logged in as admin"

    before do
      @users = [
        @user_0 = create(:user, :survey_complete, email: "aaaaaa@example.com"),
        @user_1 = create(:user, :survey_complete, email: "bbbbbb@example.com"),
        @user_2 = create(:user,                   email: "cccccc@example.com")
      ]
      visit admin_users_path
    end

    it "lists information about every user" do
      within "#admin_users_table" do
        @users.each do |user|
          is_expected.to have_content user.email
          is_expected.to have_content user.full_name if user.full_name.present?
        end
      end
    end

    it "doesn't include information about admins" do
      within "#admin_users_table" do
        is_expected.not_to have_content admin.email
      end
    end

    it "can be sorted"

    describe "typing something into the 'filter' box" do
      it "filters out users who don't match your query" do
        fill_in :admin_users_table_filter, with: "aaaaaa"
        should have_user @user_0
        should_not have_user @user_1
        should_not have_user @user_2
      end

      it "is case insensitive" do
        fill_in :admin_users_table_filter, with: "AaAAaa"
        should have_user @user_0
        should_not have_user @user_1
        should_not have_user @user_2
      end
    end

    context "when a user" do
      context "has completed the onboarding survey" do
        it "has a link to recommend them a card" do
          is_expected.to have_link "Recommend Card",
            href: new_admin_user_card_recommendation_path(@user_0)
          is_expected.to have_link "Recommend Card",
            href: new_admin_user_card_recommendation_path(@user_1)
        end
      end

      context "has not completed the onboarding survey" do
        it "does not have a link to recommend them a card" do
          is_expected.not_to have_link "Recommend Card",
            href: new_admin_user_card_recommendation_path(@user_2)
        end
      end
    end

    def have_user(user)
      have_selector "#user_#{user.id}"
    end
  end
end
