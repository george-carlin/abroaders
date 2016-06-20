# README

## Dependencies

The Ruby version is specified at the top of the Gemfile (as opposed
to one of the other ways of specifying it, like through a file called
`.ruby-version`)

We're also using node and NPM for some front-end hackery. Parts of the app use
React.JS and JSX. In order to make this work, I had to hack together a weird
setup that's a hybrid between Browserify/npm and the Rails asset pipeline.
It's not the best system but it works for now. (More detailed Javascript notes
are below.) If you have node and NPM installed on your machine, running `npm
install` should be enough to make everything work for you for now.

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
   want your PR to target `master`. If not, I'll say so on Pivotal.
3. Click 'Deliver' on Pivotal. ('Delivered' stories = there's currently a PR
   on Github awaiting feedback.) Post a comment on the Pivotal story with
   a link to the pull request on GitHub.
4. I'll have a look at the PR. If it looks good, I'll merge it and accept the
   story on Pivotal. If I spot problems, I'll decline the story on Pivotal and
   give you feedback.

## General

-  Keep line length to 80 characters or less. This doesn't have to be 100%
   strict -  the occasional 83-character line isn't going to kill anybody - but
   stick to 80 as a general principle.

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


## Rails

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

Form objects, as described in the Code Climate article. Inherit from
`ApplicationForm`. (TODO add more detailed explanation of Form objects + conventions)

#### `services`

Service objects, as described in the Code Climate article. There's only
one service object at the moment, and in retrospect this was an unecessary
abstraction. Don't add any more service objects - the one that we do have
will eventually be removed.

#### `serializers`

Serializers as used by the
[`active_model_serializers`](https://github.com/rails-api/active_model_serializers)
gem.

#### `presenters`

Close in concept to what the Code Climate article calls a 'View Object'.
TODO add more detailed explanation of Presenters.

### Javascript

- See the note at the top of this Readme about Node and React.

- No Coffeescript!

- Let's use React sparingly for now. If you need to sprinkle some dynamism
  onto the frontend, stick with Rails's UJS helpers and jQuery for now (preferably
  the former). If you think that the front-end task is too complicated for a
  jQuery-based approach, talk to George and we'll decide on a case-by-case basis.

### Testing

- We use RSpec, not minitest.

- **Always** add feature specs! Every user action in the app should be covered
  by an automated test. Lower-level testing (testing models) is helpful too,
  but it's not worth the time to add a detailed spec for every little one-line
  method.

- Generally, follow the guidelines at [betterspecs.org](http://betterspecs.org/).
  The only one I disagree with is that "A spec description should never be
  longer than 40 characters". Sure, keep your spec descriptions short when
  possible, but I see no need for a strict and specific upper limit on the
  length.

- When fixing a bug, **always, always, always** add a new test that fails
  when the bug is present and passes once the bug is fixed.

#### Feature specs

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

TODO add explanation of page objects
