require "rails_helper"

describe "spending survey" do
  # SURVEYTODO this is junk c&ped from the other spec file, needs cleaning up

  next

    # SURVEYTODO: fields to move from Passenger to SpendingInfo:
    # credit_score
    # will_apply_for_loan_true
    # will_apply_for_loan_false
    # personal_spending
    # has_business_with_ein
    # has_business_without_ein
    # has_business_no_business
    it "does not have a field for 'business spending'" do
      is_expected.not_to have_field "#{mp_prefix}_business_spending"
    end

    describe "selecting 'I have a business with EIN'", :js do
      before { choose "#{mp_prefix}_has_business_with_ein" }
      it "shows the 'business spending' input" do
        is_expected.to have_field "#{mp_prefix}_business_spending"
      end

      describe "and selecting 'I don't have a business' again" do
        before { choose "#{mp_prefix}_has_business_no_business" }
        it "hides the 'business spending' input" do
          is_expected.not_to have_field "#{mp_prefix}_business_spending"
        end
      end
    end

    describe "selecting 'I have a business without EIN'", :js do
      before { choose "#{mp_prefix}_has_business_without_ein" }
      it "shows the 'business spending' input" do
        is_expected.to have_field "#{mp_prefix}_business_spending"
      end

      describe "and selecting 'I don't have a business' again" do
        before { choose "#{mp_prefix}_has_business_no_business" }
        it "hides the 'business spending' input" do
          is_expected.not_to have_field "#{mp_prefix}_business_spending"
        end
      end
    end

      it "does not show a field for my companion's 'business spending'" do
        is_expected.not_to have_field "#{co_prefix}_business_spending"
      end

      describe "selecting 'companion has a business with EIN'", :js do
        before { choose "#{co_prefix}_has_business_with_ein" }
        it "shows the 'companion business spending' input" do
          is_expected.to have_field "#{co_prefix}_business_spending"
        end

        describe "and selecting 'companion doesn't have a business' again" do
          before { choose "#{co_prefix}_has_business_no_business" }
          it "hides the 'companion business spending' input" do
            is_expected.not_to have_field "#{co_prefix}_business_spending"
          end
        end
      end

      describe "selecting 'I have a business without EIN'", :js do
        before { choose "#{co_prefix}_has_business_without_ein" }
        it "shows the 'business spending' input" do
          is_expected.to have_field "#{co_prefix}_has_business_without_ein"
        end

        describe "and selecting 'I don't have a business' again" do
          before { choose "#{co_prefix}_has_business_no_business" }
          it "hides the 'business spending' input" do
            is_expected.not_to have_field \
                              "#{co_prefix}_has_business_without_ein"
          end
        end
      end

end
