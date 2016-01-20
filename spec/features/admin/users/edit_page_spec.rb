require "rails_helper"

describe "admin section" do
  describe "edit user page" do
    subject { page }

    include_context "logged in as admin"

    before do
      @user = create(:user)
      visit edit_admin_user_path(@user)
    end

    it "has fields for the user's information" do
      skip
    end
  end
end
