require "rails_helper"

describe "admin section" do
  describe "account pages index page", :js do
    subject { page }

    include_context "logged in as admin"

    before do
      @accounts = [
        # Specify the email addresses so we have something to test the filtering
        # with:
        create(:onboarded_account, email: "aaaaaa@example.com"),
        create(:onboarded_account, email: "bbbbbb@example.com"),
        create(:onboarded_account_with_companion, email: "ccccccc@example.com"),
        create(:account, email: "ddddddd@example.com")
      ]
      extra_setup
      visit admin_accounts_path
    end

    let(:extra_setup) { nil }
    let(:onboarded_accounts) { @accounts.slice(0,3) }

    it { is_expected.to have_title full_title("Accounts") }

    it "lists every account" do
      within "#admin_accounts_table" do
        @accounts.each do |account|
          is_expected.to have_selector account_selector(account)
        end
      end
    end

    describe "for accounts which have added a main person" do
      it "links to the person's info page" do
        onboarded_accounts.slice(0,3).each do |account|
          within account_selector(account) do
            is_expected.to have_link(
              account.owner.first_name,
              href: admin_person_path(account.owner)
            )
          end
        end
      end
    end

    describe "for accounts which have added a companion" do
      it "links to the companion's info page" do
        within account_selector(@accounts[2]) do
          is_expected.to have_link(
            @accounts[2].companion.first_name,
            href: admin_person_path(@accounts[2].companion)
          )
        end
      end
    end

    it "can be sorted"

    describe "typing something into the 'filter' box" do
      it "filters out accounts who don't match your query" do
        fill_in :admin_accounts_table_filter, with: "aaaaaa"
        should have_account @accounts[0]
        should_not have_account @accounts[1]
        should_not have_account @accounts[2]
      end

      it "is case insensitive" do
        fill_in :admin_accounts_table_filter, with: "AaAAaa"
        should have_account @accounts[0]
        should_not have_account @accounts[1]
        should_not have_account @accounts[2]
      end
    end

    context "when an account" do
      def have_recommend_card_btn_for(person)
        have_link(
          "", # actually a font-awesome icon
          href: new_admin_person_card_recommendation_path(person)
        )
      end

      def have_no_recommend_card_btn_for(person)
        have_no_link(
          "", # actually a font-awesome icon
          href: new_admin_person_card_recommendation_path(person)
        )
      end

      context "has completed the onboarding survey" do
        context "and the main person" do

          context "is not eligible to apply for cards" do
            let(:extra_setup) do
              @accounts[0].owner.eligibility.update_attributes!(eligible: false)
            end

            it "doesn't have a link to recommend the main person a card" do
              is_expected.to have_no_recommend_card_btn_for(@accounts[0].owner)
            end
          end

          context "is eligible to apply for cards but not ready" do
            let(:extra_setup) do
              @accounts[0].owner.eligibility.update_attributes!(eligible: true)
              @accounts[0].owner.readiness_status.update_attributes!(ready: true)
              @accounts[1].owner.eligibility.update_attributes!(eligible: true)
              @accounts[0].owner.readiness_status.update_attributes!(ready: false)
            end

            it "doesn't have a link to recommend them a card" do
              is_expected.to have_no_recommend_card_btn_for(@accounts[0].owner)
              is_expected.to have_no_recommend_card_btn_for(@accounts[1].owner)
            end
          end

          context "is eligible and ready to apply for cards" do
            let(:extra_setup) do
              @accounts[0].owner.eligibility.update_attributes!(eligible: true)
              @accounts[0].owner.readiness_status.update_attributes!(ready: true)
            end

            it "doesn't have a link to recommend the main person a card" do
              is_expected.to have_recommend_card_btn_for(@accounts[0].owner)
            end
          end
        end

        context "and has an eligible and ready companion" do
          let(:extra_setup) do
            @accounts[2].companion.eligibility.update_attributes!(eligible: true)
            @accounts[2].companion.readiness_status.update_attributes!(ready: true)
          end

          it "has a link to recommend the main person a card" do
            is_expected.to have_recommend_card_btn_for(@accounts[2].companion)
          end
        end
      end
    end

    def have_account(account)
      have_selector account_selector(account)
    end

    def account_selector(account)
      "##{dom_id(account)}"
    end
  end
end
