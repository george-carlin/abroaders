require "rails_helper"

describe "contact info pages" do
  subject { page }

  include_context "logged in"

  describe "new page" do
    before do
      extra_setup
      visit new_contact_info_path
    end

    let(:extra_setup) { nil }

    context "when I already have provided my contact info" do
      let(:extra_setup) { create(:contact_info, user: user) }
      it "redirects to root" do
        expect(current_path).to eq root_path
      end
    end

    it "has fields for contact info" do
      should have_field :contact_info_first_name
      should have_field :contact_info_middle_names
      should have_field :contact_info_last_name
      should have_field :contact_info_phone_number
      should have_field :contact_info_whatsapp
      should have_field :contact_info_text_message
      should have_field :contact_info_imessage
      should have_field :contact_info_time_zone
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save" }

      context "with valid information" do
        before do
          fill_in :contact_info_first_name,   with: "Fred"
          fill_in :contact_info_last_name,    with: "Bloggs"
          fill_in :contact_info_phone_number, with: "0123412341"
          fill_in :contact_info_time_zone,    with: "GMT"
        end

        it "creates a new ContactInfo" do
          expect(user.contact_info).not_to be_persisted
          submit_form
          expect(user.reload.contact_info).to be_persisted
        end
      end
    end
  end
end
