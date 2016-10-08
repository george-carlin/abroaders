# React

## Guides

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

## Conventions

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
