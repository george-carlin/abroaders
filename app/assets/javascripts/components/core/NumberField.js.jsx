import React, { PropTypes } from "react";
import classNames from "classnames";

const NumberFieldTag = require("./NumberFieldTag");

// Extend NumberFieldTag with Rails-style attributes:
//
//  <NumberField modelName="person" attribute="age" />
//  // =
//  <NumberFieldTag
//    id="person_age"
//    name="person[age]"
//  />
const NumberField = (_props) => {
  const props = Object.assign({}, _props);
  props.id   = `${props.modelName}_${props.attribute}`;
  props.name = `${props.modelName}[${props.attribute}]`;

  return <NumberFieldTag {...props} />;
};

NumberField.propTypes = Object.assign(
  {},
  NumberFieldTag.propTypes,
  {
    attribute: PropTypes.string.isRequired,
    modelName: PropTypes.string.isRequired,
  }
);

module.exports = NumberField;
