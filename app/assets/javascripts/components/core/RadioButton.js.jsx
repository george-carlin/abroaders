import React, { PropTypes } from "react";

import HTMLInput from "./shared/HTMLInput";

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
  const props = HTMLInput.getProps(_props);
  props.id += "_" + props.value;

  return <input {...props} type="radio" />;
};

RadioButton.propTypes = Object.assign(
  {},
  HTMLInput.propTypes,
  {
    checked: PropTypes.bool,
    value:   PropTypes.string.isRequired,
  }
);

module.exports = RadioButton;
