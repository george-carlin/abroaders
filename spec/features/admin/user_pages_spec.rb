require "rails_helper"

describe "admin section" do
  describe "user pages" do
    subject { page }

    include_context "logged in as admin"

    describe "index page", js: true do
      before do
        @users = [
          @user_0 = create(:user, email: "aaaaaa@example.com"),
          @user_1 = create(:user, email: "bbbbbb@example.com"),
          @user_2 = create(:user, email: "cccccc@example.com")
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

      def have_user(user)
        have_selector "#user_#{user.id}"
      end
    end


    describe "show page", js: true do

      before do
        @cards = create_list(:card, 4)
        @user  = create(:user)
        extra_setup
        visit admin_user_path(@user)
      end

      let(:extra_setup) { nil }

      context "when the user" do
        context "has no existing card accounts/recommendations" do
          it "says so" do
            should have_content t("admin.users.card_accounts.none")
          end
        end
      end

      context "has already been recommended at least one card" do
        let(:extra_setup) do
          @recommended_card = @cards.first
          @rec = create(
            :card_recommendation, user: @user, card: @recommended_card
          )
        end

        it "lists existing card recommendations" do
          should have_selector card_account_selector(@rec)
          within card_account_selector(@rec) do
            is_expected.to have_content @rec.card_identifier
            is_expected.to have_content @rec.card_name
            is_expected.to have_content @rec.card_type.to_s.capitalize
            is_expected.to have_content @rec.card_brand.to_s.capitalize
            is_expected.to have_content @rec.card_type.to_s.capitalize
            is_expected.to have_content @rec.card_bank_name
          end
        end
      end

      it "has a form to recommend a new card" do
        @cards.each do |card|
          should have_selector "input#card_account_card_id_#{card.id}"
        end
      end

      describe "filtering cards"

      def card_account_selector(account)
        "#card_account_#{account.id}"
      end

    end # show page
  end
end
