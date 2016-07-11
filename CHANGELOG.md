# CHANGELOG

## July 2016

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
