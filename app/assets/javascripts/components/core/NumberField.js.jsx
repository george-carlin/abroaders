import React, { PropTypes } from "react";

import HTMLInput from "./shared/HTMLInput";

const NumberFieldTag = require("./NumberFieldTag");

// Extend NumberFieldTag with Rails-style attributes:
//
//  <NumberField modelName="person" attribute="age" />
//  // =
//  <NumberFieldTag
//    id="person_age"
//    name="person[age]"
//  />
const NumberField = (props) => {
  return <NumberFieldTag {...HTMLInput.getProps(props)} />;
};

NumberField.propTypes = Object.assign(
  {},
  NumberFieldTag.propTypes,
  HTMLInput.propTypes
);

module.exports = NumberField;
