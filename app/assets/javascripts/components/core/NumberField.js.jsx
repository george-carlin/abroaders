import React, { PropTypes } from "react";
const classNames = require("classnames");

// modelName: "person", attribute: "age", will create an input button with
// name="person[age]". This keeps things in line with the attribute names in a
// normal Rails form.
const NumberField = (_props) => {
  const props = Object.assign({}, _props);

  const id   = `${props.modelName}_${props.attribute}`;
  const name = `${props.modelName}[${props.attribute}]`;

  props.className = classNames([
    props.className,
    {
      "form-control": true,
      "input-sm":     props.small,
    },
  ]);

  return <input id={id} name={name} type="number" {...props} />;
};

NumberField.propTypes = {
  attribute: PropTypes.string.isRequired,
  modelName: PropTypes.string.isRequired,
  small:     PropTypes.bool,
};

module.exports = NumberField;
