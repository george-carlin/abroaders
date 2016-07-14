# CHANGELOG

## July 2016

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
