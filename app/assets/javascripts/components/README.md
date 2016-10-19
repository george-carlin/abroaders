# React

## Guides/Conventions

-   You don't *have* to use JSX for every file. If a component is very simple,
    and especially if it's just a stateless wrapper around a single HTML tag,
    feel free to just use a `.js` file with `React.createElement`

        # Questionable:
        # ContrivedComponent.js.jsx
        const ContrivedComponent = (props) => {
          return <div id={foobar(props.id) />;
        };

        # Better:
        # ContrivedComponent.js
        const ContrivedComponent = (props) => {
          return React.createElement("div", { id: foobar(props.id) });
        };

-   See react_ujs.js and application.js for info about how to output React
    components in our view.

-   Only one React component per file.

-   Store the React component as a variable with `const`, then export that
    variable at the bottom of the file, as opposed to just exporting the
    component directly:

        # Bad:
        export default React.createClass({
          ...
        });

        # Good:
        const MyComponent = React.createClass({
          ...
        });

        export default MyComponent;

    This means that the friendly name `<MyComponent>` appears in the React dev
    tools browser extension, which helps with debugging.

-   For 'core' components which return a form field (i.e. `<input>`, `<select>`,
    `<textarea>`), separate responsibilities in a way that mirrors Rails's
    view helpers.

    E.g. for a component that returns a text field:

    - `<TextFieldTag>` returns a simple `<input type="text">`, with some
      additional Bootstrap CSS classes, e.g. `form-control input-sm`.
    - `<TextField>` takes all the sames props as TextFieldTag, plus two
      additional props `modelName` and `attribute`, which add these properties
      to the input: `id="model_name_attribute" name="model_name[attribute]"`

    This is analogous to the difference between the Rails helpers
    `text_field_tag` and `text_field`.

- When a component can be broken down into sub-components, and it doesn't
  make sense to use those sub-components anywhere else, put it all into one
  directory with a `package.json` file:

        app/assets/javascripts/components/MyComponent
        ├── MyComponent.js.jsx
        ├── MySubComponent.js.jsx
        └── package.json

        // package.json
        {
          "name": "CardApplicationSurvey",
          "version": "0.0.1",
          "private": true,
          "main": "./CardApplicationSurvey.js.jsx"
        }

  At this stage, there's no reason to update the 'version' string of our
  components when we make changes. It's not worth the effort. Maybe we'll start
  doing this once our app and team get bigger.

  When a component is small and simple enough to not need breaking down, keep
  it all in one file and don't bother putting it in a directory (so no
  package.json)
