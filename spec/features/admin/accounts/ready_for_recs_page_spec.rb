require "rails_helper"

describe "admin section" do
  describe "ready for recs page", :js do
    def have_account(account)
      have_selector account_selector(account)
    end

    def account_selector(account)
      "##{dom_id(account)}"
    end

    def number_to_currency(amount)
      ActiveSupport::NumberHelper.number_to_currency(amount)
    end

    shared_examples "displaying user name with label" do
      context "is not eligible to apply for cards" do
        let(:extra_setup) do
          person.update_attributes!(eligible: false, ready: false)
        end

        it "doesn't have an 'E' or an 'R' by their name" do
          expect(page).to have_link(name, href: href, exact: true)
        end
      end

      context "is eligible to apply for cards but not ready" do
        let(:extra_setup) do
          person.update_attributes!(eligible: true, ready: false)
        end

        it "has an 'E' by their name" do
          expect(page).to have_link("#{name} (E)", href: href, exact: true)
        end
      end

      context "is eligible and ready to apply for cards" do
        let(:extra_setup) do
          person.update_attributes!(eligible: true, ready: true)
        end

        it "has an 'R' by their name" do
          expect(page).to have_link("#{name} (R)", href: href, exact: true)
        end
      end
    end

    subject { page }

    include_context "logged in as admin"

    before do
      @accounts = [
        create(:account, :ready, email: "aaaaaa@example.com"),
        create(:account, :with_companion, :ready, email: "bbbbbb@example.com")
      ]
      @unready_account = create(:account, :onboarded, email: "ddddddd@example.com")
      extra_setup
      visit ready_for_recs_admin_accounts_path
    end

    let(:account_without_companion) { @accounts[0] }
    let(:account_with_companion)    { @accounts[1] }
    let(:extra_setup) { nil }

    it { is_expected.to have_title full_title("Ready for Recs.") }

    it "lists every ready account" do
      within "#admin_accounts_table" do
        @accounts.each do |account|
          expect(page).to have_selector account_selector(account)
        end
      end
    end

    it "doesn't show unready account" do
      within "#admin_accounts_table" do
        expect(page).to have_no_selector account_selector(@unready_account)
      end
    end

    it "links to the account owners' info pages" do
      @accounts.each do |account|
        within account_selector(account) do
          expect(page).to have_link(
            account.owner.first_name,
            href: admin_person_path(account.owner)
          )
        end
      end
    end

    it "links to the account pages" do
      @accounts.each do |account|
        within account_selector(account) do
          expect(page).to have_link(
            "See",
            href: admin_account_path(account)
          )
        end
      end
    end

    it "shows monthly spending of accounts" do
      @accounts.each do |account|
        within account_selector(account) do
          expect(page).to have_content(number_to_currency(account.monthly_spending_usd))
        end
      end
    end

    describe "for accounts which have added a companion" do
      it "links to the companion's info page" do
        within account_selector(account_with_companion) do
          expect(page).to have_link(
            account_with_companion.companion.first_name,
            href: admin_person_path(account_with_companion.companion)
          )
        end
      end
    end

    describe "typing something into the 'filter' box" do
      it "filters out accounts who don't match your query" do
        fill_in :admin_accounts_table_filter, with: "aaaaaa"
        expect(page).to have_account @accounts[0]
        expect(page).not_to have_account @accounts[1]
      end

      it "is case insensitive" do
        fill_in :admin_accounts_table_filter, with: "AaAAaa"
        expect(page).to have_account @accounts[0]
        expect(page).not_to have_account @accounts[1]
      end
    end

    context "when an account with companion" do
      let(:owner)     { account_with_companion.owner }
      let(:companion) { account_with_companion.companion }

      context "and the account owner" do
        let(:person) { account_with_companion.owner }
        let(:name)   { person.first_name }
        let(:href)   { admin_person_path(person) }

        include_examples "displaying user name with label"
      end

      context "and companion" do
        let(:person) { account_with_companion.companion }
        let(:name)   { person.first_name }
        let(:href)   { admin_person_path(person) }

        include_examples "displaying user name with label"
      end

      context "and owner and companion both ready and have some card accounts" do
        let(:extra_setup) do
          create_list(:card_account, 2, person: owner)
          create_list(:card_account, 2, person: companion)
        end

        it "display both person card accounts count" do
          within account_selector(account_with_companion) do
            expect(page).to have_content(owner.card_accounts.count + companion.card_accounts.count)
          end
        end
      end

      context "and only owner is ready and have some card accounts" do
        let(:extra_setup) do
          companion.update_attributes(ready: false)
          create_list(:card_account, 2, person: owner)
          create_list(:card_account, 2, person: companion)
        end

        it "display only owner card accounts count" do
          within account_selector(account_with_companion) do
            expect(page).to have_content(owner.card_accounts.count)
          end
        end
      end

      context "and owner and companion don't have any card accounts" do
        it "display zero card accounts count" do
          within account_selector(account_with_companion) do
            expect(page).to have_content(0)
          end
        end
      end
    end

    context "when account without companion" do
      let(:person) { account_without_companion.owner }
      let(:name)   { person.first_name }
      let(:href)   { admin_person_path(person) }

      context "is not ready" do
        let(:extra_setup) do
          person.update_attributes!(ready: false)
        end

        it "doesn't displaying on the page" do
          expect(page).to have_no_selector account_selector(person.account)
        end
      end

      context "is ready" do
        it "has an 'R' by their name" do
          expect(page).to have_link("#{name} (R)", href: href, exact: true)
        end

        context "and has some card accounts" do
          let(:extra_setup) do
            create_list(:card_account, 2, person: person)
          end

          it "display card accounts count" do
            within account_selector(person.account) do
              expect(page).to have_content(person.card_accounts.count)
            end
          end
        end

        context "and doesn't have any card accounts" do
          it "display zero card account count" do
            within account_selector(person.account) do
              expect(page).to have_content(0)
            end
          end
        end
      end
    end
  end
end
