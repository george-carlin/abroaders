# README

## Getting Started

TODO: add instructions for how a new developer can set up the app in their
development environment

## General

-  Keep line length to 80 characters or less. This doesn't have to be 100%
   strict the occasional 83-line character isn't going to kill anybody - but stick
   to 80 as a general principle.

-  We don't support IE &lt; 10. If someone doesn't want to upgrade to a modern
   browser, that's their problem, not ours.

## Ruby

- Generally speaking, we follow [GitHub's Ruby style guide](https://github.com/styleguide/ruby)

## Rails

### Controllers

- Arrange the standard `resources` methods in this

### Concepts

As well as the standard Rails concepts (models, controllers, views, etc,)
we have some extra top level folders in `/app`. They're mostly based on
[this excellent article from Code Climate](blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/).

#### `forms`

Form objects, as described in the Code Climate article. Inherit from
`ApplicationForm`. (TODO add more detailed explanation of Form objects + conventionsA)

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

- No Coffeescript!

- We're using React.JS (with JSX) on some pages. In order to make this work,
  we're using a weird set-up that's a hybrid between Browserify/npm and
  the Rails asset pipeline. It's not the best system but it works for now. TODO
  add more detailed explanation of the setup.

### Testing

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

TODO add explanation of page objects
