require "rails_helper"

describe "the spending info survey" do
  let(:account) { create(:account, shares_expenses: shares_expenses) }
  before do
    create(:main_passenger, account: account)
    if has_companion
      create(:passenger, :companion, account: account)
    end
    login_as account, scope: :account
    visit survey_spending_path
  end
  subject { page }

  DEFAULT_SPENDING_FIELDS = %i[
    credit_score
    will_apply_for_loan_true
    will_apply_for_loan_false
    has_business_with_ein
    has_business_without_ein
    has_business_no_business
  ]

  let(:ps_prefix) { "spending_survey" }
  let(:mp_prefix) { "#{ps_prefix}_main_spending_info_attributes" }
  let(:co_prefix) { "#{ps_prefix}_companion_spending_info_attributes" }

  let(:shares_expenses) { false }

  shared_examples "business spending input" do |opts={}|
    my        = opts[:companion] ? "my" : "my companion's"
    i_have    = opts[:companion] ? "I have" : "my companion has"
    dont_have = opts[:companion] ? "I don't have" : "my companion doesn't have"

    let(:prefix) { opts[:companion] ? co_prefix : mp_prefix }

    it "does not have a field for #{my} business spending" do
      is_expected.not_to have_field "#{prefix}_business_spending"
    end

    {
      'with_ein' => 'with EIN', 'without_ein' => 'without EIN'
    }.each do |key, human|
      describe "selecting '#{i_have} a business #{human}'", :js do
        before { choose "#{prefix}_has_business_#{key}" }

        it "shows #{my} 'business spending' input" do
          is_expected.to have_field "#{prefix}_business_spending"
        end

        describe "and selecting '#{dont_have} a business' again" do
          before { choose "#{prefix}_has_business_no_business" }
          it "hides the 'business spending' input again" do
            is_expected.not_to have_field "#{prefix}_business_spending"
          end
        end
      end
    end
  end

  describe "when I don't have a travel companion" do
    let(:has_companion) { false }

    it "asks me for my spending info" do
      DEFAULT_SPENDING_FIELDS.each do |field|
        is_expected.to have_field "#{mp_prefix}_#{field}"
      end
    end

    it "doesn't ask anything about a travel companion" do
      DEFAULT_SPENDING_FIELDS.each do |field|
        is_expected.not_to have_field "#{co_prefix}_#{field}"
      end
    end

    include_examples "business spending input"

    pending "submitting the form"
  end # when I don't have a travel companion

  describe "when I have a travel companion" do
    let(:has_companion) { true }

    it "asks for my and my companion's spending info" do
      DEFAULT_SPENDING_FIELDS.each do |field|
        is_expected.to have_field "#{mp_prefix}_#{field}"
        is_expected.to have_field "#{co_prefix}_#{field}"
      end
    end

    describe "and we share expenses" do
      let(:shares_expenses) { true }

      it "has a single input for our shared personal spending" do
        is_expected.to have_field "#{mp_prefix}_personal_spending"
        is_expected.not_to have_field "#{co_prefix}_personal_spending"
      end
    end

    describe "and we don't share expenses" do
      let(:shares_expenses) { false }

      it "has two inputs, one for each of our personal spending" do
        is_expected.to have_field "#{mp_prefix}_personal_spending"
        is_expected.to have_field "#{co_prefix}_personal_spending"
      end
    end

    include_examples "business spending input"
    include_examples "business spending input", companion: true

    pending "submitting the form"
  end
end
