import React, { PropTypes } from "react";
import classNames from "classnames";

// Extend TextFieldTag with Rails-style attributes:
//
//  <TextField modelName="person" attribute="name" />
//  // =
//  <TextFieldTag
//    id="person_name"
//    name="person[name]"
//  />
const TextFieldTag = require("./TextFieldTag");

const TextField = (_props) => {
  const props = Object.assign({}, _props);
  props.id   = `${props.modelName}_${props.attribute}`;
  props.name = `${props.modelName}[${props.attribute}]`;

  return <TextFieldTag {...props} />;
};

TextField.propTypes = Object.assign(
  {},
  TextFieldTag.propTypes,
  {
    attribute: PropTypes.string.isRequired,
    modelName: PropTypes.string.isRequired,
  }
);

module.exports = TextField;
