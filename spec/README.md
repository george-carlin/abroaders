# Testing

Some general guidelines for how we test:

- We use RSpec, not minitest. Run the specs using the `rspec` command. But you
  already knew that.

- Feature specs are the most important part of the test suite. Every user
  action in the app should be covered by a feature spec unless there's a good
  reason not to.  Lower-level testing (e.g. testing models) is helpful too, but
  it's not worth the time to add a detailed spec for every little one-line
  method.

- Generally, follow the guidelines at [betterspecs.org](http://betterspecs.org/).
  The only one I disagree with is that "A spec description should never be
  longer than 40 characters". Sure, keep your spec descriptions short when
  possible, but I see no need for a strict and specific upper limit on the
  length.

- When fixing a bug, **always, always, always** add a new test that fails
  when the bug is present and passes once the bug is fixed.

- Favor shallow nesting with `example` over deeply nested specs with lots of
  `describe` blocks. Using lots of nested `describe` and `before` blocks
  reduces repetition in tests but can make them much harder to read; don't be
  afraid to make the specs a little bit repetitive for the sake of readability.

        # bad:
        describe "filling in the form" do
          before { fill_in :phone_number, with: phone_number }

          describe "with an invalid phone number" do
            let(:phone_number) { "not a number" }

            it "doesn't create a PhoneNumber" do
              expect do
                click_button "Submit"
              end.not_to change{PhoneNumber.count}
            end
          end

          describe "with a valid phone number" do
            let(:phone_number) { "555 1234 000" }

            it "creates a PhoneNumber" do
              expect do
                click_button "Submit"
              end.to change{PhoneNumber.count}.by(1)
            end

            describe "that is foreign" do
              let(:phone_number) { "+34 555 123 456" }

              it "creates a foreign PhoneNumber" do
                fill_in :phone_number, with: ""
                expect do
                  click_button "Submit"
                end.to change{PhoneNumber.count}.by(1)
                expect(PhoneNumber.last).to be_foreign
              end
            end
          end
        end


        # good:
        example "submitting the form with invalid information" do
          fill_in :phone_number, with: "not a number"
          expect do
            click_button "Submit"
          end.not_to change{PhoneNumber.count}
        end

        example "submitting the form with valid information" do
          fill_in :phone_number, with: "555 1234 000"
          expect do
            click_button "Submit"
          end.to change{PhoneNumber.count}.by(1)
        end

        example "submitting the form with a foreign phone number " do
          fill_in :phone_number, with: ""
          expect do
            click_button "Submit"
          end.to change{PhoneNumber.count}.by(1)
          expect(PhoneNumber.last).to be_foreign
        end

  An advantage of the deeply-nested approach is that the spec descriptions read
  more naturally: "filling in the form with a valid phone number that is
  foreign creates a foreign PhoneNumber" in the above 'bad' example. But it doesn't
  matter: no-one is going to read the spec descriptions except programmers who
  are smart enough to understand the 'less natural' description.

  Note that there are a lot of existing tests which use a deeply-nested
  approach in the style of the above 'bad' example. This is because we
  originally favoured this approach but eventually decided to switch. It's not
  worth changing the old specs; they can be refactored when we naturally come
  to new reasons to update them (e.g. if we're changing the behaviour that they
  test). But any new tests should be created in the new style.

  Also note that 'favor shallow nesting' is a guideline, not a hard-and-fast
  rule. It's okay to occasionally nest a `describe` block within another
  `describe` block if you think the trade-off between readability and
  conciseness is worth it. Use your judgement.

- Don't use `is_expected` except in one-line specs.

        subject { page }

        # Bad
        it "shows an alert" do
          is_expected.to have_selector ".alert"
        end

        # Good
        it { is_expected.to have_selector ".alert" }

## Feature Specs

- Feature specs are generally the slowest part of the test suite, so it makes
  sense to combine multiple expectations into one so that we don't slow down
  the tests even further by performing the same setup again and again:


        # Bad:
        describe "the card recommendation" do
          it "says when it was made" do
            expect(page).to have_selector ".card_account_recommended_at", "05/05/2016"
          end

          it "says when it was applied for" do
            expect(page).to have_selector ".card_account_applied_at", "05/07/2016"
          end

          it "says when it was opened" do
            expect(page).to have_selector ".card_account_opened_at", "05/09/2016"
          end
        end

        # Good:
        specify "card recommendation displays the correct dates" do
          expect(page).to have_selector ".card_account_recommended_at", "05/05/2016"
          expect(page).to have_selector ".card_account_applied_at", "05/07/2016"
          expect(page).to have_selector ".card_account_opened_at", "05/09/2016"
        end

  See also [BetterSpecs on this topic](http://betterspecs.org/#single) (the
  final paragraph of that section).

- When you want to test that an element is *not* present on the page, use
  `to` and a negatively worded Capybara matcher, rather than `not_to` and
  a positively worded one.

        # Bad:
        expect(page).not_to have_button "Confirm"
        expect(page).not_to have_selector "#card_1"
        expect(page).not_to have_link "Click me"

        # Good
        expect(page).to have_no_button "Confirm"
        expect(page).to have_no_selector "#card_1"
        expect(page).to have_no_link "Click me"

    Using `not_to` as above will slow down the tests dramatically. Read
    [this article](https://blog.codeship.com/faster-rails-tests/) to understand
    why.

### Page Objects

In some of the feature specs (especially those related to the `/cards` page)
I (George) have been experimenting with an abstraction called "Page Objects",
heavily inspired by [this ThoughtBot article](https://robots.thoughtbot.com/better-acceptance-tests-with-page-objects)
(although the way I've done it is not exactly the same as the approach in that
article.) I like the page object concept, but I haven't quite figured out the
best way to do it, and there and some inconsistencies in the way I've been
doing it with the page objects I've already created.

I need to think about this more heavily and more clearly define the way that
page objects should work and how we should use them. In the meantime, don't
worry about page objects for now and don't create any new ones.


