# CHANGELOG

## June 2016

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
