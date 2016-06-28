require "rails_helper"

describe "accounts/dashboard/person" do

  let(:person)  { create(:person) }
  let(:account) { person.account }

  before do
    account.onboarded_travel_plans = onboarded_travel_plans
    account.onboarded_type         = onboarded_type
    account.monthly_spending_usd   = 1500 if onboarded_type
    account.save!

    create(:person, account: account, main: false) if partner_account
  end

  let(:onboarded_travel_plans) { true }
  let(:onboarded_type) { true }
  let(:partner_account) { false }

  let(:rendered) do
    render partial: "accounts/dashboard/person", locals: { person: person }
  end
  subject { rendered }

  shared_examples "balances" do
    context "and hasn't completed the balances survey" do
      before { raise if person.onboarded_balances? } # sanity check
      it "says to do so before cards can be recommended" do
        is_expected.to have_content \
          "You have not added any frequent flyer balances for this "\
          "person. In order to make the best credit card recommendation, "\
          "we need to know if this person already has any existing "\
          "frequent flyer balances."
        is_expected.to have_link add_balances,
          href: survey_person_balances_path(person)
      end
    end

    context "and has completed the balances survey" do
      before { person.update_attributes!(onboarded_balances: true) }

      it "doesn't have a link to add balances" do
        is_expected.not_to have_content \
          "You have not added any frequent flyer balances for this "\
          "person. In order to make the best credit card recommendation, "\
          "we need to know if this person already has any existing "\
          "frequent flyer balances."
        is_expected.not_to have_link add_balances,
          href: survey_person_balances_path(person)
      end

      context "but has no balances" do
        it {
          is_expected.to have_content "No existing frequent flyer balances"
        }
      end

      context "and added some balances" do
        let!(:currencies) { create_list(:currency, 2) }
        before do
          create(:balance, person: person, currency: currencies[0], value: 12_345)
          create(:balance, person: person, currency: currencies[1], value: 543_543)
        end

        it "displays info about them" do
          is_expected.to have_content "#{currencies[0].name}: 12,345"
          is_expected.to have_content "#{currencies[1].name}: 543,543"
        end
      end
    end
  end # shared_examples: balances

  let(:add_travel_plan)  { "Add your first travel plan" }
  let(:choose_type)      { "Choose account type" }
  let(:add_spending)     { "Add financial information" }
  let(:add_cards)        { "Add existing cards" }
  let(:add_balances)     { "Add balances" }
  let(:update_readiness) { "Update readiness status" }

  context "when the account needs to add its first travel plan" do
    let(:onboarded_travel_plans) { false }
    let(:onboarded_type) { false }
    it "has a link to add a travel plan" do
      is_expected.to have_link "Add your first travel plan", href: new_travel_plan_path
    end

    it "doesn't have links to other parts of the survey" do
      is_expected.not_to have_link choose_type
      is_expected.not_to have_link add_spending
      is_expected.not_to have_link add_cards
      is_expected.not_to have_link add_balances
      is_expected.not_to have_link update_readiness
    end
  end

  context "when the account has added its first travel plan" do
    before { raise unless account.onboarded_travel_plans? } # sanity check
    it "doesn't have a link to add a travel plan" do
      is_expected.not_to have_link add_travel_plan
    end
  end

  # This also covers the case where we don't know if the person is eligible;
  # they select eligiblity at the same point they choose an account type.
  context "when the account needs to select its type" do
    let(:onboarded_type) { false }
    it "has a link to choose the type" do
      is_expected.to have_link choose_type, href: type_account_path
    end
  end

  context "when the account has selected its type" do
    before { raise unless account.onboarded_type? } # sanity check
    it "doesn't have a link to choose the type" do
      is_expected.not_to have_link choose_type
    end
  end

  context "when the person is ineligible to apply for cards" do
    before { person.update_attributes!(eligible: false) }
    it "says so" do
      # sanity check
      raise unless person.onboarded_eligibility? && person.ineligible?
      is_expected.to have_content "Ineligible to apply for cards"
    end

    it "doesn't have links to eligible-only parts of the survey" do
      is_expected.not_to have_link add_spending
      is_expected.not_to have_link add_cards
      is_expected.not_to have_link update_readiness
    end

    context "when the person has added their balances" do
      before { person.update_attributes!(onboarded_balances: true) }
      it "doesn't have a links to the readiness survey" do # bug fix
        is_expected.not_to have_link update_readiness
      end
    end

    include_examples "balances"
  end

  context "when the person is eligible to apply for cards" do
    before { person.update_attributes!(eligible: true) }

    it "says so" do
      is_expected.to have_content "Eligible to apply for cards"
    end

    context "and hasn't completed the spending survey" do
      it "says to do so before cards can be recommended" do
        is_expected.to have_content \
          "You have not added this person's financial details"
        is_expected.to have_link add_spending,
            href: new_person_spending_info_path(person)
      end
    end

    context "and has completed the spending survey" do
      before do
        person.create_spending_info!(
          credit_score: 456,
          will_apply_for_loan: true,
          has_business: "without_ein",
          business_spending_usd: 1234,
        )
      end

      it "displays it" do
        is_expected.to have_content "Credit score: 456"
        is_expected.to have_content "Business spending: $1,234.00"
        is_expected.to have_content "(Does not have EIN)"
        is_expected.to have_content "Will apply for loan in next 6 months: Yes"
      end

      context "when the account is a Solo Account" do
        let(:partner_account) { false }
        it "displays the 'personal spending'" do
          is_expected.to have_content "Personal spending: $1,500.00/month"
        end
      end

      context "when the account is a Partner Account" do
        let(:partner_account) { true }
        it "displays the 'shared spending'" do
          is_expected.to have_content "Shared spending: $1,500.00/month"
        end
      end

      pending do
        is_expected.to have_link "Edit", href: edit_person_spending_info_path(person)
      end

      context "and hasn't completed the cards survey" do
        before { raise if person.onboarded_cards? } # sanity check
        it "says to add them before cards can be recommended" do
          is_expected.to have_content \
            "Before we can recommend any credit cards to this person, "\
            "we need to know which cards they already have."
          is_expected.to have_link add_cards,
              href: survey_person_card_accounts_path(person)
        end
      end

      context "and has completed the cards survey" do
        before do
          person.update_attributes!(onboarded_cards: true)
          create_list(:card_account, 2, person: person)
        end

        pending "it displays a summary of the person's card info"

        include_examples "balances"

        context "and has added balances" do
          before { person.update_attributes!(onboarded_balances: true) }

          context "and hasn't said whether or not they're ready to apply" do
            before { raise if person.readiness_given? } # sanity check
            it "has a link to say when they're ready" do
              is_expected.to have_link update_readiness,
                href: new_person_readiness_status_path(person)
            end
          end

          context "and has said that they're not ready to apply" do
            before { person.unready_to_apply! }
            it "has a link to say when they're ready" do
              is_expected.to have_link update_readiness,
                href: new_person_readiness_status_path(person)
            end
          end

          context "and has said that they're ready to apply" do
            before { person.ready_to_apply! }
            it "doesn't have a link to say they're ready" do
              is_expected.not_to have_link update_readiness
            end
          end
        end
      end
    end
  end
end
