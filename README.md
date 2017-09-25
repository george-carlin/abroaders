# README

Welcome to the Abroaders web app! Here's what you need to know:

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
want to write a similar script that will work on Windows - `bin/setup.exe`? -
be my guest)

Have a look inside the `bin/setup` script if you have problems, or want to
learn more about what's going on.

Tell me (George) immediately if `bin/setup` doesn't work smoothly for you!
There may be some steps that I've missed and it's important I keep the script
updated and working well for every new developer.

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

Honestly, our NPM/front-end set up is a crappy solution that I hacked together
in the early days of the app and never got around to coming up with something
better. In the long run, we're probably better off ditching the asset pipeline
entirely and using an NPM-like setup for the entire front-end (perhaps using
Yarn?) 

You'll also need imagemagick installed for the
[paperclip](https://github.com/thoughtbot/paperclip) gem to work correctly.

If you're on a Mac, I recommend installing [Homebrew](http://brew.sh/) and
using that to install packages such as imagemagick.

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

We're using [Trailblazer 2](http://trailblazer.to) on top of Rails. Make sure
you familiarise yourself with how Trailblazer works because it's integral to
our setup. There are many cases where we completely ignore the "Rails way"
(gasp!) and follow Trailblazer conventions instead.

We still have a few old things lying around from before we made the switch
to Trailblazer - such as my crappy 'form objects' abstraction in app/forms.
These oldies are considered deprecated and should eventually be removed.

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

All business logic should live in operations. I heard it from Nick Sutterer (creator of Trailblazer) himself: an operation is anything that change's an app's state.

- Operation names should follow the format `Concept::Operations::Verb`. (TODO we should probably change `Operations` to the singular to match `Concept::Cell`.)

### Cells

Some general notes (by no means complete):

- Cells inherit from `Trailblazer::Cell`, not `Cell::ViewModel`.

- All cells live within `app/concepts` and are nested within a module called `Cell`, e.g. `Person::Cell::Show`.

- Document a Cell's `.call` method like so:

        class Widget < Widget.superclass
          module Cell
            # A description of what the cell is for and what it renders
            #
            # @!method self.call(model, opts = {})
            #   @param model [Widget]
            #   @option opts [String] name
            class List < Trailblazer::Cell
              ...

- Remember that, unlike Rails views, Cells don't escape HTML automatically, so make sure that all user-generated content is escaped before it gets displayed on the page. See [HTML Escaping](http://trailblazer.to/gems/cells/api.html#html-escaping) in the Cells docs. If the `Escape` module won't cut it for whatever reason, you can escape things with `ERB::Util.html_escape`.

- Any code which directly references one of the cell's dependencies (such as another nested cell), or the `options` hash, should be put in the `.rb` file for the cell rather than in the `.erb` file for the view:

        # BAD:
        # view:
        <% if options[:flag] %>
          <%= cell(OtherCell) %>
        <% end %>

        # GOOD:
        # cell:
        def other
          if options[:flag]
            cell(OtherCell)
          else
            ''
          end
        end

        # view:
        <%= other %>

When it's all in the `.rb` file, you can scan or search the file to get a quick idea of its dependencies and of what the possible `options` are. If you put them in the view you could easily miss them. (Of course, the dependencies and the available options should also be explicitly documented, but keeping everything within one file reduces the chances of making a mistake in the documentation or letting the docs become out-of-date.)

## Testing Cells

- Stick `require 'cells_helper'` at the top of files which test cells. This file loads the Rails environment (in future hopefully we can obviate the need for this), and adds some extra RSpec configuration to specs which it determines to be 'cell specs'. It considers a spec to be a cell spec if it meets any of these criteria:

1. the file path contains the exact word 'cell' or 'cells', or
2. the spec is marked with `type: :cell`.

For all cell specs, the helper then:

- Includes the macros from the `rspec-cells` gem (such as `cell`). Note that this also gives access to Capybara methods like `have_content`, `have_link` etc.

- Includes our custom macros from `Abroaders::RSpec::CellMacros`, which is also defined in `cell_helper` (take a look).

- Most of the time you'll want to render cells in tests using the `show` macro, which assumes that the `described_class` is the cell that you want to test.

- Note that negative matchers like `have_no_link` aren't available in cell specs, but it doesn't matter because you don't need them - unlike in feature specs, you can just write `expect(...).not_to have_link(...)` and it won't slow anything down because there's no AJAX to worry about.

- If a cell needs to use the app's route helpers, you probably want to add the line `controller RelevantController` to your spec file.

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
    common Rails pattern, done to redce repetition, but it sucks because
    it hides too much and makes the code *less* clear, not more.

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

### Emails

- Remember to add a plain text `.txt(.erb)` email template as well as the
  `.html(.erb)` one.

- Emails will usually be enqueued as background jobs using `deliver_later`,
  so see everything in `app/jobs/README.md` regarding background jobs.
