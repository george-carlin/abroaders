require "rails_helper"

describe "admin section" do
  describe "account pages index page", :js, :manual_clean do
    subject { page }

    include_context "logged in as admin"

    before(:all) do
      @accounts = [
        # Specify the email addresses so we have something to test the filtering
        # with:
        create(:onboarded_account, email: "aaaaaa@example.com"),
        create(:onboarded_account, email: "bbbbbb@example.com"),
        create(:onboarded_account_with_companion, email: "ccccccc@example.com"),
        create(:account, email: "ddddddd@example.com")
      ]
    end

    before do
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

    it "links to the account owners' info pages" do
      onboarded_accounts.each do |account|
        within account_selector(account) do
          is_expected.to have_link(
            account.owner.first_name,
            href: admin_person_path(account.owner)
          )
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
      context "has completed the onboarding survey" do
        context "and the account owner" do
          let(:owner) { @accounts[0].owner }
          let(:name)  { owner.first_name }
          let(:href)  { admin_person_path(owner) }

          context "is not eligible to apply for cards" do
            let(:extra_setup) do
              owner.eligibility.update_attributes!(eligible: false)
            end

            it "doesn't have an 'E' or an 'R' by their name" do
              is_expected.to have_link(name, href: href, exact: true)
            end
          end

          context "is eligible to apply for cards but not ready" do
            let(:extra_setup) do
              owner.eligibility.update_attributes!(eligible: true)
              owner.readiness_status.update_attributes!(ready: false)
            end

            it "has an 'E' by their name" do
              is_expected.to have_link("#{name} (E)", href: href, exact: true)
            end
          end

          context "is eligible and ready to apply for cards" do
            let(:extra_setup) do
              owner.eligibility.update_attributes!(eligible: true)
              owner.readiness_status.update_attributes!(ready: true)
            end

            it "has an 'R' by their name" do
              is_expected.to have_link("#{name} (R)", href: href, exact: true)
            end
          end
        end

        context "and has an eligible and ready companion" do
          let(:companion) { @accounts[2].companion }
          let(:extra_setup) do
            companion.eligibility.update_attributes!(eligible: true)
            companion.readiness_status.update_attributes!(ready: true)
          end

          it "has an 'R' next to the companion's name" do
            href = admin_person_path(companion)
            is_expected.to have_link("#{companion.first_name} (R)", href: href, exact: true)
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
