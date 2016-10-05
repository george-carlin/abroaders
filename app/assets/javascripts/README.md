# Javascript Notes, Rules, and Guidelines

- See the note in `README.md` about Node and React. Our front-end setup is
  a total mess at the moment; we're using `browserify-rails` and have a weird
  hybrid of NPM/Browserify and the asset pipeline. React-related files
  go in `app/assets/javascripts/components` and are loaded via Browserify and
  transpiled using Babel. Other Javascript files go in
  `app/assets/javascripts/other` or `vendor/assets/javascripts` and are loaded
  via the asset pipeline; but this means these files aren't preprocessed by
  Babel and so can't use JSX or many ES6 features.

  In the near future we're going to scrap the asset pipeline and use NPM for
  everything.

- No Coffeescript!

- Let's use React sparingly for now. If you need to sprinkle some dynamism
  onto the frontend, stick with Rails's UJS helpers and jQuery for now (preferably
  the former). If you think that the front-end task is too complicated for a
  jQuery-based approach, talk to George and we'll decide on a case-by-case basis.

- When adding 3rd party JS (or CSS) to `vendor/assets`, it's preferable to add
  the unminified version. The asset pipeline will automatically minify it in
  production anyway, and in development keeping it non-minified will make
  debugging easier (e.g. if we need to step through the JS line-by-line in the
  console.)

- We're using ESLint, and our rules are defined in `.eslintrc`. Some of these
  rules are overwritten for 'other' JS by the file
  `app/assets/javascripts/other/.eslintrc`.

  All newly written JS code should pass ESLint.

- We're targeting ES6 (AKA ES2015) and transpiling to ES5 using Babel. JS tests
  are running in the PhantomJS environment, which sadly isn't the
  best-maintained bit of software out there and is still lacking some ES5
  features. We're shimming/polyfilling these missing features into PhantomJS
  but we may have missed some. Tell George if you're having any issues with
  PJS compatability.

- Put a new `const` and `let` on each line; don't use commas.

        # Good
        const foo = 3;
        const bar = 5;
        let age  = 25;
        let name = "George";

        # Bad
        const foo = 3,
              bar = 5;
        let age  = 25,
            name = "George";

- Favor `import` over `require`. This lets us do fancy stuff like
  `import React, { PropTypes } from "react";` instead of 

## React.JS

- require files in this order:

        import React, { PropTypes } from "react"; // react first
        import { each }   from "underscore"; // other 3rd-party packages
        import classnames from "classnames";

        import Form from "../core/Form" // core components

        import MenuItem from "./MenuItem" // sub-components of the current one

        const Menu = React.createClass({
          ...

- use stateless functional components whenever possible:
 
        # Bad - the person class doesn't have any state, and simply renders
        # deterministic HTML based on its props - therefore there's no reason
        # to use a fullblown React class.
        const Person = React.createClass({
          propTypes: {
            name: PropTypes.string.isRequired,
          },

          render() {
            return (
              <div id="person">
                <span className="name">
                  {this.props.name}
                </span>
              </div>
            );
          },
        });

        # Good
        const Person = ({name}) => {
          return (
            <div id="person">
              <span className="name">
                {name}
              </span>
            </div>
          );
        };

        Person.propTypes = {
          name: PropTypes.string.isRequired,
        };

- TODO - should we be using React.createClass or ES6 classes?




