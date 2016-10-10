import React, { PropTypes } from "react";

import HTMLInput      from "./shared/HTMLInput";
import NumberFieldTag from "./NumberFieldTag";

// Extend NumberFieldTag with Rails-style attributes:
//
//  <NumberField modelName="person" attribute="age" />
//  // =
//  <NumberFieldTag
//    id="person_age"
//    name="person[age]"
//  />
const NumberField = (props) => {
  return React.createElement(NumberFieldTag, HTMLInput.getProps(props));
};

NumberField.propTypes = Object.assign(
  {},
  NumberFieldTag.propTypes,
  HTMLInput.propTypes
);

export default NumberField;
