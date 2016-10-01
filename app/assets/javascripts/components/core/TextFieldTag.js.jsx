import React, { PropTypes } from "react";
const classNames = require("classnames");

// TODO: rename this to "TextField" and create another component called
// "TextFieldTag".  TextField inherits from TextFieldTag, and the difference is
// the same as the difference between the Rails helpers text_field and
// text_field_tag
const TextFieldTag = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classNames([
    props.className,
    {
      "form-control": true,
      "input-sm":     props.small,
    },
  ]);

  const id   = `${props.modelName}_${props.attribute}`;
  const name = `${props.modelName}[${props.attribute}]`;

  delete props.attribute;
  delete props.modelName;

  return (
    <input
      {...props}
      id={id}
      name={name}
      type="text"
    />
  );
};

TextFieldTag.propTypes = {
  attribute: PropTypes.string.isRequired,
  modelName: PropTypes.string.isRequired,
  small:     PropTypes.bool,
};

module.exports = TextFieldTag;
