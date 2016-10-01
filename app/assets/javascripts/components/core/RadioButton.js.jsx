import React, { PropTypes } from "react";

// Extend <input type="radio" with Rails-style attributes:
//
//  <RadioButton modelName="person" attribute="ready" value="true" />
//  // =
//  <input
//    type="radio"
//    id="person_ready_true"
//    name="person[ready]"
//    value="true"
//  />
const RadioButton = (_props) => {
  const props = Object.assign({}, _props);
  props.id   = `${props.modelName}_${props.attribute}_${props.value}`;
  props.name = `${props.modelName}[${props.attribute}]`;

  return <input {...props} type="radio" />;
};

RadioButton.propTypes = {
  attribute: PropTypes.string.isRequired,
  checked:   PropTypes.bool,
  modelName: PropTypes.string.isRequired,
  value:     PropTypes.string.isRequired,
};

module.exports = RadioButton;
