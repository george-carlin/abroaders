# CHANGELOG

## October 2016

*   Convert `Bank` and `Alliance` to real ActiveRecord models.
    Remove `FakeDBModel`. Pivotal Tracker #132586099

    *Boris Shatalov*

*   remove uniqueness constraint on `balances: [:person_id, :currency_id]`.
    d7af34b.

    *George Millo*

*   Fix security issue where users could view and update each other's
    card accounts(!). b40cb4a5d0e

    *George Millo*

*   Bug fix: travel plan points estimate table was calculating estimates
    for 'from' to 'from', not 'from' to 'to'

    *George Millo*

*   Huge changes to the onboarding survey flow + architecture (some subtasks of
    which are already noted in other bullet points below). GH #68

    *George Millo, Anatols Baymaganov, Boris Shatalov*

*   Use `Airport` for travel plan's from/to instead `Country`.
    Pivotal Tracker #132586099

    *Boris Shatalov*

*   Replace dashboard with profile complete page.
    Show old dashboard only if any person on the account has
    received recommendations. Pivotal Tracker #132295779

    *Boris Shatalov*

*   Add `regions of interest` page. PT #130901163

    *Boris Shatalov*

*   Updates to the travel plan form. Pivotal Tracker #130904549

    *Anatols Baymaganov*

*   Add readiness question at the end of the onboarding survey.
    Pivotal Tracker #131360373 GH #54

    *Boris Shatalov*

*   Remove unused module `CurrentUserHelper`.

    *George Millo*

*   Rename `people.main` to `people.owner`. PT #129923947 GH #63

    *Boris Shatalov*

*   Extract `Airport#full_name`. `f6baa57d`

    *George Millo*

*   Add a `<noscript>` tag telling users to turn JS on. `d4edb203`, `69aa4ba3`

    *George Millo*

*   Add `<Cols>` component and `columnClassnames.js` helper for adding
    bootstrap CSS classes. `287dd89`, `925cfacfb`

    *George Millo*

*   Bug fix: make `ApplicationForm#save!` and `update!` raise errors correctly;
    0c1beb100

    *George Millo*

*   Bug fix when users click balance survey buttons before JS has finished
    loading; 74c34321e

    *George Millo*

*   Avoid boilerplate when passing params to Virtus; b480a842

    *George Millo*

*   Add ESLint and Rubocop to our workflow and get both tools passing.

    *George Millo*

*   Create a helper method 'n' that intelligently displays "you"
    or a person's name depending on whether or not the current
    account has a companion. Pivotal Tracker #130622249, GH #49

    *Boris Shatalov*

*   Standardise partner/couples/companion terminology

    *George Millo*

*   Add <HiddenField> component
    *George Millo*

*   Add PostAffiliatePro tracking code

    *George Millo*

*   Remove LeadDyno tracking code

    *George Millo*

## September 2016

*   Add rake task for sending the annual fee notification email to a user.
    Pivotal Tracker #130313781, GH #44

    *Boris Shatalov*

*   Add `type` attribute to currencies; only show currencies of type 'airline'
    in list of admin filters.

    *George Millo*

*   Group `Currency` filters by `Alliance` on admin/people#show.
    Pivotal Tracker #129920759

    *Boris Shatalov*

*   Users can add their home airports in the onboarding survey.
    Pivotal Tracker #126319005, #41

    *Boris Shatalov*

*   Add `AccountSerializer`, `PersonSerializer`, and `SpendingInfoSerializer`.
    GH #51

    *Boris Shatalov, George Millo*

*   Display points+fees estimate on travel plan form. PT #131029753

    *George Millo*

*   Allow line breaks in the emails of Recommendation Notes.
    Make urls inside rec. note clickable.
    Pivotal Tracker #130913419, GH #50

    *Boris Shatalov*

*   Offers have a attribute called "partner". Pivotal Tracker #130490251, GH#48

    *Anatols Baymaganov*

*   Big update to our airports and cities data using the data we got
    from miles.biz

    *George Millo*

*   Remove `State` model. Make validations on `Destination#parent.type` more
    restrictive.

    *George Millo*

*   Create one page for update account ready status with url: `readiness/edit`.
    Pivotal Tracker #126036139

    *Boris Shatalov*

*   Add sorting for `admin/people#show` card accounts table.
    Update jquery.tablesorter. Pivotal Tracker #129894535

    *Boris Shatalov*

*   Add ability to edit `SpendingInfo`. Pivotal Tracker #129983961

    *Boris Shatalov*

*   Use jQuery.slideUp/Down to hide/show cards on the survey page.
    Pivotal Tracker #125094181

    *Boris Shatalov*

*   Add ability to edit "from survey" `CardAccount`. Pivotal Tracker #129985309

    *Boris Shatalov*

*   Allow line breaks in Recommendation Notes. Pivotal Tracker #124290791

    *Boris Shatalov*

*   Move checkboxes from admin/people#show page to above the user's cards section.
    Add "toggle all" checkbox for currencies. Pivotal Tracker #129842813

    *Boris Shatalov*

*   Extract `ApplicationRecord#belongs_to_fake_db_model`

    *George Millo*

*   Create `FakeDBModel` and `Alliance`. Add alliance_id to `Currency`.
    Pivotal Tracker #129919413

    *Boris Shatalov*

*   Upgrade to Rails 5.0.0.1. Pivotal Tracker #129987043

    *Boris Shatalov*

*   Add "shown_on_survey" field to `Currency`. Pivotal Tracker #129920005

    *Boris Shatalov*

*   Hide "{name} is unready for cards" message if user has recently received
    card recommendations. Pivotal Tracker #129806913

    *Boris Shatalov*

*   Update the onboarding survey to save last day of month for opened/closed
    dates of card accounts. Pivotal Tracker #129807083

    *Boris Shatalov*

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

