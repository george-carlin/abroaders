import React, { PropTypes } from "react";

// modelName: "person", attribute: "ready", value="true" will create a radio
// button with name="person[ready]" and value="true". This keeps things in line
// with the attribute names in a normal Rails form
const RadioButton = (_props) => {
  const props = Object.assign({}, _props);
  const id    = `${props.modelName}_${props.attribute}_${props.value}`;
  const name  = `${props.modelName}[${props.attribute}]`;

  delete props.modelName;
  delete props.attribute;

  return (
    <input
      {...props}
      checked={props.checked}
      id={id}
      name={name}
      type="radio"
    />
  );
};

RadioButton.propTypes = {
  attribute: PropTypes.string.isRequired,
  checked:   PropTypes.bool,
  modelName: PropTypes.string.isRequired,
  value:     PropTypes.string.isRequired,
};

module.exports = RadioButton;
