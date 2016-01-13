require "rails_helper"

describe "admin section" do
  describe "user pages" do
    subject { page }

    describe "index page", js: true do
      include_context "logged in as admin"

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
  end
end
