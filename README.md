# README

## Dependencies

The Ruby version is specified at the top of the Gemfile (as opposed
to one of the other ways of specifying it, like through a file called
`.ruby-version`)

We're also using node and NPM for some front-end hackery. Parts of the app use
React.JS and JSX. In order to make this work, I had to hack together a weird
setup that's a hybrid between Browserify/npm and the Rails asset pipeline.
It's not the best system but it works for now. (More detailed Javascript notes
can be found in `app/assets/javascripts/README.md`.) If you have node and NPM
installed on your machine, running `npm install` should be enough to make
everything work for you for now.

You'll also need imagemagick installed for the
[paperclip](https://github.com/thoughtbot/paperclip) gem to work correctly.

If you're on a Mac, I recommend installing [Homebrew](http://brew.sh/) and
using that to install packages such as imagemagick.

## Getting Started

```
git clone git@github.com:georgemillo/abroaders.git
cd abroaders
cp config/database.yml.sample  config/database.yml
# Edit database.yml with your local PostgreSQL settings, as necessary
bin/setup
```

Note that `bin/setup` is intended for *nix operating systems. There's no
guarantee that it will work on Windows. If you're on Windows, look in
`bin/setup` and figure out what the equivalent steps are for your OS. (If you
want to write a similar script that will work on Windows - `bin/setup.exe`?, be
my guest)

Have a look inside the `bin/setup` script if you have problems, or want to
learn more about what's going on.

Tell me (George) immediately if `bin/setup` doesn't work smoothly for you!
There may be some steps that I've missed and it's important I keep the script
updated and working well for every new developer!

The setup script should also seed your database with some sample data,
including some admin accounts. Get the admin login info from
`lib/tasks/seed.rake` and you can log in at `/admin/sign_in`. (Remember that
'normal' user accounts log in at `/sign_in`.

We use the gem [figaro](https://github.com/laserlemon/figaro) to manage ENV
variable settings. With Figaro, your ENV variables are stored in the file
`config/application.yml`, which is gitignored. The setup script will create a
basic application.yml file for you which should contain all the ENV info
you need for basic development.

## Workflow + Branching model

The `production` branch is the latest commit that's live and deployed to Heroku.

The `master` branch contains the current state of deployment. In theory,
features shouldn't be merged into `master` until they're finished, approved,
and ready to deploy. This means that `master` should always have a green test
suite.

When you start working on a new feature:

1. Click **Start** on the Pivotal Tracker story.
2. Fork a new branch off of `master`:

        git checkout master
        git checkout -b my-branch

3. Perform all work on this new branch. Keep pushing to Github at regular
   intervals.

When you're done with the story:

1. Click 'Finish' on Pivotal.
2. Push your final work to Github, and open a new pull request. You'll usually
   want your PR to target `master`. If not, I'll say so on PT.
      - Side note: for some big features, we'll want to break things down
        into multiple stories on PT, but it won't make sense to deploy the
        changes to production until *all* the related PT stories are complete.
        In this case we'll want to create an intermediary branch called e.g.
        `name-of-feature` and the 'intermediary' stories will be merged into
        this branch, not `master` (because, remember, `master` should be
        deployable at any time and shouldn't contain half-finished features).
        When the entire feature is completed we'll then merge `name-of-feature`
        into `master`.
3. Click 'Deliver' on Pivotal. ('Delivered' stories = there's currently a PR
   on Github awaiting feedback.) Post a comment on the Pivotal story with
   a link to the pull request on GitHub.
4. I'll have a look at the PR. If it looks good, I'll merge it and accept the
   story on Pivotal. If I spot problems, I'll decline the story on Pivotal and
   give you feedback.

### Completing features + deployment

- If a story is *Accepted* on PT, that should mean that the feature is
  finished, merged into `master`, and the test suite on `master` is passing.
- When merging a feature into `master`, note the number of the PT story and the
  the Github pull request in the commit message of the merge commit. (This is
  so we can easily find it later if we're looking at old commits and think 'why
  did we do it this way?' so want to see any discussion that took place on GH
  and PT.)
- When merging new features, always add a merge commit (i.e. don't allow
  fast-forwards). You can ensure this by passing `--no-ff` to `git merge`.
  These makes the git history easier to follow and makes it easier to revert
  changes.
- To deploy to production, just merge the `master` branch into `production`
  and push `production` to GitHub. Codeship will then pull `production` from
  GitHub and, if the test suite passes, it will deploy it automatically to

Note that our workflow/branching/deployment procedure has evolved and changed
over the app's lifespan, and we haven't always followed our own rules
perfectly, so some older commits won't have followed the above procedures.

## General

- The golden rule: write **readable, understandable** code. Code is read far
  more times than it is written, and developers are more expensive than
  processing power. In an ideal world, another programmer should be able to
  pick up where you've left off and modify/improve/fix your code with only the
  bare minimum amount of time spent understanding what your code already does.

  I like how it's put in [this quote](http://stackoverflow.com/a/410799/1603071)
  from Stack Overflow:

  > "Your job (as a programmer) is to put yourself out of work.
  >
  > When you're writing software for your employer, any software that you
  > create is to be written in such a way that it can be picked up by any
  > developer and understood with a minimal amount of effort. ....
  >
  > If you get hit by a bus, laid off, fired, or walk off the job, your
  > employer should be able to replace you on a moment's notice, and the next
  > guy could step into your role, pick up your code and be up and running
  > within a week tops. If he or she can't do that, then you've failed
  > miserably.
  >
  > Interestingly, I've found that having that goal has made me more valuable
  > to my employers. The more I strive to be disposable, the more valuable I
  > become to them."

-  Keep line length to 80 characters or less. This doesn't have to be 100%
   strict -  the occasional 83-character line isn't going to kill anybody - but
   stick to 80 as a general principle.

-  Only use `.gitignore` to ignore files that are actually specific to Rails
   and to the codebase itself. If you want to ignore files that are specific to
   your own IDE or text editor (`.swp`, `.idea`, etc), those belong in a
   [global gitignore file](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore)
   on your own machine, not in this codebase's `.gitignore`.

## Browser support

-  We don't support IE &lt; 10. If someone doesn't want to upgrade to a modern
   browser, that's their problem, not ours.

## Ruby

- Generally speaking, we follow
  [GitHub's Ruby style guide](https://github.com/styleguide/ruby), with at
  least one exception: use Ruby 1.9 hash key syntax instead of hashrockets:

        # bad:
        { :key => "value" }

        # good:
        { key: "value" }

- Keep the Gemfile organised like so:

        source 'http://rubygems.org'

        ruby '2.3.0' # ruby version

        gem 'rails', '5.0.0' # rails and version

        # All other gems, in alphabetical order
        gem 'algo'
        gem 'quelque_chose'
        gem 'something', '~> 4.1.0' # version number if necessary to specify it

        # env-specific gems, in this order.
        group :production do
          gem 'a' # still alphabetical
          gem 'b'
          gem 'c'
        end

        group :development, :test do
          # ...
        end

        group :development do
          # ...
        end

        group :test do
          # ...
        end

        # platform-specific gems:
        gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

    I don't see much need for filling the Gemfile with comments explaining
    what each gem does; if someone wants to know what a gem does they can
    look in the gem's own README or documentation. But I'm not saying *never*
    add an explanatory comment to the Gemfile either, just do it sparingly.

- Don't upgrade the dependencies unless you have a good reason to (i.e. we
  want to use a new feature that's not available in the version we currently
  use; the current version has a bug, or the current version is incompatible
  with a different dependency that we want to install or upgrade.) Bundler
  makes it so easy to upgrade dependencies that it can make you complacent:
  there's never a guarantee that an upgraded gem hasn't broken something
  somewhere, and every dependency upgrade needs a new round of testing and QA.
  (This is especially true as the codebase and userbase grow bigger)

## Trailblazer

We're using [Trailblazer 2](http://trailblazer.to) on top of Rails.

### File Structure

For a concept called `user` within `app/concepts`, add dirs `cell`, `view`, and
`operations` as necessary:

    ├── user
    │   ├── cell
    │   │   └── cell_name.rb
    │   ├── operations
    │   │   └── new.rb
    │   │   └── create.rb
    │   └── view
    │       ├── user.css.scss
    │       └── cell_name.erb

### Operations

All business logic should live in operations. TODO expand.

- Operation names should follow the format `Concept::Operations::Verb`. (TODO we should probably change `Operations` to the singular to match `Concept::Cell`.)

### Cells

- There are essentially two types of cells: 'high level' ones which contain all
  the HTML for a given page and which are rendered from the controller using
  `render cell(Cell)`, and 'lower level' ones which render smaller fragments of
  HTML and text and which will be used internally by the higher level cells.
  The different between the two is basically the same as the difference between
  a view in a partial in Rails. Perhaps we should have namespaced our cells
  separately to reflect this, but it's too late to bother now. For the purposes
  of this guide I'll call them 'view cells' and 'partial cells'.

- A cell's "model" is the first argument that it gets passed, which can
  be anything and which is available in the cell as `model`. Its "options"
  are the second argument when rendering, which must be a hash (or nil).

- By convention, view cells should take a Trailblazer Result object as their
  model. They can pull out whatever information they need from the result
  themselves. Following this convention simplifies our controllers means that
  all our cells have a consistent API, and it means that if we change something
  about how the result object works then it's much less likely that we'll need
  to change the controller.

- Partial cells can use model whatever you want, but it should generally be
  an ActiveRecord model. If the cell only needs to use a particular attribute
  of a model, pass in the whole model anyway:

        # GOOD
        # app/concepts/user/cell/show.erb
        <%= email %>

        # app/concepts/user/cell/show.rb
        def email
          model.email.nil? ? 'None provided' : model.email
        end

        # rendering
        cell(User::Cell::Show, user)

        # BAD
        # app/concepts/user/cell/show.erb
        <%= email %>

        # app/concepts/user/cell/show.rb
        def email
          options[:email].nil? ? 'None provided' : options[:email]
        end

        # rendering
        cell(User::Cell::Show, nil, email: user.email)

  The above 'bad' example isn't terrible, but what if we need to use not just
  the user's email but 3 or 4 of its attributes? That quickly results in a lot
  of ugly boilerplate every time we want to render the cell. And what if the
  requirements later change and we need to use a bunch of extra attributes from
  the user, or something about the user changes and we need to update how
  we get its email? If each attribute is being passed in individually, the API
  is extremely fragile and will require changes in multiple places every
  time the requirements change. By passing in the whole user object, then
  it's likely that all future changes can be safely handled within the cell
  itself's code.

  This is in line with Trailblazer's approach of passing the entire `params`
  hash into each operation rather than extracting a subset of the params within
  the controller.

- Generally, a partial cell should accept an object that matches the outermost part
  of its name. E.g. if the cell is called
  `TravelPlan::Cell::FurtherInformation`, it should be called like
  `TravelPlan::Cell::FurtherInformation.(travel_plan)`, rather than
  `TravelPlan::Cell::FurtherInformation.(travel_plan.further_information)`.
  I've found it's easier to use this blanket approach and let the cell get the
  precise data it needs from the `model` than to create cells with a more
  complex API that inevitably requires a bunch of boilerplate every time the
  cell is called.

- Remember that, unlike Rails views, Cells don't escape HTML automatically, so
  make sure that all user-generated content is escaped before it gets displayed
  on the page. See [HTML Escaping](http://trailblazer.to/gems/cells/api.html#html-escaping)
  in the Cells docs.

## Rails

### General

- When something needs to update more than one record or database table at
  once, and it doesn't make logical sense for one update to happen without
  the other, wrap the Ruby code in a transaction:

        # Bad:
        def transfer_money(other_person, amount)
          me.update_attributes!(balance: me.balance - amount)
          other_person.update_attributes!(balance: other_person.balance.amount)
        end

        # If there's an unforeseen error that makes the above method crash
        # halfway through - perhaps a server crash, or a bug in
        # `other_person.update_attributes!` that sneaks its way into
        # production, then one user will have lost money without the other
        # gaining it. Using a transaction ensures that the database will
        # only be updated if the entire transaction is run successfully:

        # Good:
        def transfer_money(other_person, amount)
          ApplicationRecord.transaction do
            me.update_attributes!(balance: me.balance - amount)
            other_person.update_attributes!(balance: other_person.balance.amount)
          end
        end

### Controllers

- Arrange the standard `resources` methods in this order:

        class ExampleController < ApplicationController

          def index
          end

          def show
          end

          def new
          end

          def create
          end

          def edit
          end

          def update
          end

          def destroy
          end
        end

    Any non-standard methods go after `destroy`, in alphabetical order.

-   Use `before_action` to redirect users away from actions they shouldn't
    be able to access. If you can fit the whole thing into 80 characters,
    pass a block to `before_action` and put it all on one line. Else, put
    it within a private method (the method's name should end with a `!`.)

        class ExampleController
          before_action { redirect_to ban_notice_path if current_user.banned? }
          before_action :disallow_minors!

          .
          .
          .

          private

          def disallow_minors!
            if current_user.age < 18
              flash[:warning] = "You are too young to visit this page"
              redirect_to root_path
            end
          end
        end

    *Don't* use `before_action` to initialize instance variables. This is a
    common Rails pattern, done in the sake of repitition, but it sucks because
    it hides too much and makes the code less clear, not more.

    If you want to extract repetitive code that loads data from the DB, put it
    in a private method with a name that starts with `load_`.

        # Bad
        before_action :initialize_post, only: [:show, :edit]

        def show
        end

        def edit
        end

        private

        def initialize_post
          @post = Post.find(params[:id])
        end

        # Good
        def show
          @post = load_post
        end

        def edit
          @post = load_post
        end

        private

        def load_post
          Post.find(params[:id])
        end

    [Further reading](http://craftingruby.com/posts/2015/05/31/dont-use-before-action-to-load-data.html)


-   Remember, just because you can't access a controller action by clicking
    around in the browser, that doesn't mean it's inaccessible: a user can very
    easily bypass the browser by making HTTP requests directly to the server.
    In the worst case, this can expose major security holes in the app. In
    milder cases, a user might be able to save 'bad' data into the DB that they
    wouldn't be able to create through the normal flow of the app.

    Make sure that at the start of each action (or in a before_action filter)
    you catch any users who shouldn't be there and redirect them away to a more
    sensible place. For example, users who aren't eligible to apply for cards
    shouldn't be able to add spending info, which means they shouldn't be able
    to visit SpendingControllers#new. As well as making sure they don't see any
    *links* to this page in the browser, we also need to add a redirect within
    the controller:

        # (this is pseudo-code)
        def new
          unless @person.eligible_to_apply?
            redirect_to root_path
          end
          @spending_info = @person.spending_info.new
        end

        # (The same logic should also be added to `create`)

### Concepts

As well as the standard Rails concepts (models, controllers, views, etc,)
we have some extra top level folders in `/app`. They're mostly based on
[this excellent article from Code Climate](blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/).

#### `forms`

TODO - this will be removed soon in favour of Trailblazer

#### `serializers`

Serializers as used by the
[`active_model_serializers`](https://github.com/rails-api/active_model_serializers)
gem. TODO this should also be removed, in favour of representers with the `representable` gem.

#### `presenters`

See `app/presenters/README.md`

### Background Jobs

- Background jobs are queued using Resque, which uses `Redis` to store data
  about each job. Redis is just a simple key-value datastore, which means
  that **it can only store basic datatypes like numbers and strings**.

  So the following code won't work:

      widget = Widget.find(1)
      UpdateWidget.perform_later(widget)

      # within app/jobs/update_widget.rb:
      def perform(widget)
        widget.update!
      end

  ... because instances of 'Widget' can't be stored in Redis. You can fix
  this by passing in the ID instead:

      UpdateWidget.perform_later(1)

      # app/jobs/update_widget.rb:
      def perform(widget_id)
        widget = Widget.find(widget_id)
        widget.update!
      end

- Remember that you don't know in advance when a background job will be
  performed, so there's no guarantee that (e.g.) the database will still be in
  the same state when the job is performed that it was when the job was
  enqueued. So, for example, code like this is risky:

      card_account.update_attributes!(something)
      NotifyAdminOfUpdate.perform_later(card_account.id)

      # app/jobs/notify_admin_of_update.rb:
      def perform(card_account_id)
        ca = CardAccount.find(card_account_id)
        Admin.notify("Card Account ##{ca.id} was updated at #{ca.updated_at}")
      end

  The problem is that the card account may have been updated *again* since you
  queued the job, so the admin will get a notification with the more recent
  timestamp, which probably isn't what you intended.

  When it's important that the background job uses *current* data, pass the
  data in directly instead of relying on pulling it out of the DB later:

      card_account.update_attributes!(something)
      NotifyAdminOfUpdate.perform_later(card_account.id, card_account.updated_at)

      # app/jobs/notify_admin_of_update.rb:
      def perform(card_account_id, updated_at)
        Admin.notify("Card Account ##{card_account_id} was updated at #{updated_at}")
      end

### Views + Layouts

We're using a Bootstrap theme that we bought. Most views should have a structure
like this:

```
<div class='hpanel'>
  <div class='panel-heading hbuilt'>
    My header
  </div>
  <div class='panel-body'>
    My freakin' sweet content
  </div>
</div>
```

Remove the 'hbuilt' class from the `panel-heading` div and it'll lose the
white background.

Don't wrap the `hpanel` in any `row`/`col-*`-class divs, unless it's to
make the `hpanel` use less than the full width of the screen. A good
set of col classes to use is:
`col-xs-12 col-sm-10 col-sm-offset-1 col-md-8 col-md-offset-2`. `hpanel`
doesn't affect width at all, so don't be afraid to stick `hpanel` and `col-*`
classes on the same div>

You can put `row`/`col-*-` divs within `panel-heading` and `panel-body`, but
you don't have to.

The original Bootstrap theme (which is called 'homer') uses a header panel on
some pages with a class called `normalheader`, but don't use that in our app.
The theme also provides a `panel-footer` class which you can stick at the
bottom of an hpanel; use it sparingly.

### Emails

- Remember to add a plain text `.txt(.erb)` email template as well as the
  `.html(.erb)` one.

- Emails will usually be enqueued as background jobs using `deliver_later`,
  so see everything in `app/jobs/README.md` regarding background jobs.

# Third Party Scripts

If we have a `<script>` tag from a third party that we want to drop into our app:

1.  Put it in a new view in `app/views/shared/third_party_scripts`.
2.  Stick the view name in the array at the top of
    `app/views/shared/third_party_scripts.rb`

The script will now be output at the bottom of the `<body>` tag.

Note that if you add a new layout (at the time of writing we just have
`application.html.erb` and `basic.html.erb`), you'll need to add the line `<%=
render "shared/third_party_scripts" %>` to the bottom of the `<body>` tag if
you want the scripts to be included.
