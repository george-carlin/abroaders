# CHANGELOG

## September 2016

*   Admin can edit a user's travel plans

    *Boris Shatalov*

*   Admin recieves an email when a user updates his/her status from 'not ready'
    to 'ready'.

    *George Millo*

*   Clicking the filter checkboxes on admin/people#show hides/shows the user's
    existing cards as well as the recommendable cards.

    *George Millo*

*   Get rid of the separation between "Recommendations" and "Other cards" on
    admin/people#show - just show all cards in the same table.

    *George Millo*

*   Recommending a card now saves via AJAX rather than requiring a full page load

    *George Millo*

*   Remove the `EventTracking` module and put the `track_intercom_event` method
    directly in `AuthenticatedUserController`.

    *George Millo*

*   Reduce the scope of what Form objects do - they're for **validating** and
    **persisting** data, and shouldn't have side effects like sending emails or
    tracking Intercom events. Those side effects are responsibilities of the
    controller; move all such code from form objects to the controller layer.

    *George Millo*

*   Add 'rel="nofollow"' to all offer links

    *George Millo*

## August 2016

*   Don't show dates of actions (applied, denied etc) to the user for card recs
    on /cards.

    *George Millo*

*   Remove 'readiness' page from survey; ask this question on the spending info
    survey instead.

    *George Millo*

*   `track_intercom_event` RSpec matcher is now aliased as
    `track_intercom_events` and can test that multiple Intercom events are
    tracked at once.

    *George Millo*

*   Make all Form Objects use Virtus if they weren't already. Remove
    ApplicationForm#attr_boolean_accessor, as it's now no longer necessary.

    *George Millo*

*   Remove ReadinessStatus model from project.
    Add 'ready' and 'unreadiness_reason' to Person.

    PT #127564851

    *Ryan Vredenburg*

*   Add tracking code for Heap

    *George Millo*

*   Refactor: Move third-party script views to their own dir

    *George Millo*

*   Add tracking code for Lead Dyno. PT #127239949

    *George Millo*

*   Visual bug fix: edit travel plan form is wrapped in a white panel,
    like the new travel plan already was.

    *George Millo*

*   Refactor: all logic related to onboarding survey completeness/redirection
    is now handled by a model called `OnboardingSurvey`.

    *George Millo*

*   Convert `Destination` model to use single-table inheritance and have
    five subclasses: `Region`, `City`, `State`, `City`, `Airport`.

    *George Millo*

## July 2016

*   Add more offer type descriptions. PT #122495941

    *Ryan Vredenburg*

*   Feature: Add unskippable card recommendation modal with timer.
    After accepting modal, user won't see it again for 24 hours.

    PT #127162065, #127163709

    *Ryan Vredenburg*, *George Millo*

*   Card application survey saves data via AJAX, not via a full page load.

    *George Millo*

*   UI fix: Some 'Cancel' btns in the Application Survey had the wrong colour.

    *George Millo*

*   Change survey completion e-mail timestamp to integer.

    *Ryan Vredenburg*

*   Rename the `ERIKS_EMAIL` env var to `ADMIN_EMAIL`.

    *George Millo*

*   Update admin e-mail after account survey completion

    *Ryan Vredenburg*

*   Feature: admins can pull recommendations that they've previously made

    *George Millo*

*   Feature: Add 'Verify' button and functionality to each offer on review page.
    Remove 'Done' button and review_all functionality.

    *Ryan Vredenburg*

*   Refactor: rename 'NonAdminController' to 'AuthenticatedUserController'.

    *Ryan Vredenburg*

*   Bug fix: CardAccount status predicate methods (`accepted?`, `closed?`) etc
    were always returning true.

    *George Millo*

*   When a user hasn't interacted with a recommendation (e.g. by clicking its
    link) after 15 days, the recommendation will expire and the user will no
    longer see it.

    *George Millo*

*   Admins can see a card recommendation's ‘seen at’ date.

    *George Millo*

*   Bug fix: recommendation CSV export was using the users' *oldest*
    recommendation when it should have been using their *newest* one.

    *George Millo*

*   Feature: users can view and edit their balances, and add new balances
    outside of the onboarding survey

    *George Millo*

*   Make the second argument to `ObjectOnPage.button` optional

    *George Millo*

*   Refactor: rename `ModelOnPage` to `RecordOnPage`.

    *George Millo*

*   Upgraded to Rails 5.0.0. Hooray!

    *George Millo*

*   Remove the placeholder 'your recs are coming soon' notice from the user
    dashboard.

    *George Millo*

*   Feature: user receives an email when admin marks recs as complete

    *George Millo*

## June 2016

*   Refactor: combine duplicative `MonthlySpending` React components into a
    single component.

    *George Millo*

*   Onboarding survey asks users to optionally provide a phone number

    *George Millo*

*   Remove the 'Eligibility' model; refactor so that this information is stored
    in a new column on the `people` table.

    *George Millo*

*   Admins can download a CSV file containing information about all accounts
    and their most recently received recommendation.

    *George Millo*

*   Allow admins to recommend cards to *anybody*, not just users who are
    onboarded and ready. Remove the 'new card recommendation' page and
    keep everything under admin/people#show.

    *George Millo*

*   Add some ActiveRecord hackery in spec/support that lets you create
    records in before(:all) in JS tests and get them automatically cleaned up
    afterwards.

    *George Millo*
