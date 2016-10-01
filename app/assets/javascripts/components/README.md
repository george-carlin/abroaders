# React



## Conventions

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
