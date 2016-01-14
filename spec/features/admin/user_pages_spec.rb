require "rails_helper"

describe "admin section" do
  describe "user pages" do
    subject { page }

    include_context "logged in as admin"

    describe "index page", js: true do
      before do
        @users = create_list(:user, 5)
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

      it "can be filtered"

    end

    describe "show page" do

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
          end
        end
      end

      it "has a form to recommend a new card" do
        should have_field :card_account_card_id
      end

      describe "filtering cards"

      def card_account_selector(account)
        "#card_account_#{account.id}"
      end

    end # show page
  end
end
